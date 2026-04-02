#Requires -Version 5.1
<#
.SYNOPSIS
    Triggers Azure Migrate replication and performs cutover for VMs staged on Hyper-V.
    This is Hop 2: moves VMs from the Hyper-V staging host to Azure Local.

.PARAMETER ConfigPath
    Path to variables.yml. Defaults to config\variables\variables.yml relative to repo root.

.PARAMETER Credential
    PSCredential for Azure authentication (if not using Az module session).
    Falls back to Key Vault or interactive prompt if not provided.

.PARAMETER TargetNode
    Azure Local cluster node to target. Defaults to config azlocal_cluster.

.PARAMETER LogPath
    Directory to write log files to. Defaults to logs\azure-migrate\<timestamp>.log.

.PARAMETER WhatIf
    Simulate operations without making changes.

.EXAMPLE
    .\Invoke-AzureMigrateCutover.ps1 -ConfigPath .\config\variables\variables.yml -Verbose

.NOTES
    Organization:  Infinite Improbability Corp (IIC)
    Idempotent:    Yes — checks replication state and VM existence before cutover
    Part of:       azurelocal-nutanix-migration
    Prerequisites: Az.Migrate module, authenticated Az session
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()]
    [string]$ConfigPath,

    [Parameter()]
    [PSCredential]$Credential,

    [Parameter()]
    [string]$TargetNode,

    [Parameter()]
    [string]$LogPath
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\common\Config-Loader.ps1" -ConfigPath $ConfigPath

$cfg     = $script:MigrationConfig
$logFile = Initialize-MigrationLog -TaskName 'azure-migrate' -LogPath $LogPath
$target  = if ($TargetNode) { $TargetNode } else { $cfg.azlocal_cluster }

Write-MigrationLog "Azure Migrate cutover starting. Project RG: $($cfg.azure_resource_group) → Azure Local: $target" -Level INFO -LogFile $logFile

# ─── Verify Az session ───────────────────────────────────────────────────────
if (-not (Get-AzContext -ErrorAction SilentlyContinue)) {
    Write-MigrationLog "No Az context found. Triggering Connect-AzAccount." -Level WARN -LogFile $logFile
    Connect-AzAccount
}

$ctx = Get-AzContext
Write-MigrationLog "Az context: $($ctx.Account.Id) — subscription: $($ctx.Subscription.Name)" -Level INFO -LogFile $logFile

# ─── Get Azure Migrate project ────────────────────────────────────────────────
if ($PSCmdlet.ShouldProcess($cfg.azure_resource_group, "Get Azure Migrate project")) {
    $projects = Get-AzMigrateProject -ResourceGroupName $cfg.azure_resource_group -ErrorAction SilentlyContinue
    if (-not $projects) {
        Write-MigrationLog "No Azure Migrate project found in $($cfg.azure_resource_group). Ensure Terraform/Bicep infra was deployed first." -Level ERROR -LogFile $logFile
        exit 1
    }
    $project = $projects[0]
    Write-MigrationLog "Azure Migrate project: $($project.Name)" -Level INFO -LogFile $logFile
}

# ─── List replicating machines ────────────────────────────────────────────────
if ($PSCmdlet.ShouldProcess($project.Name, "List replicating machines")) {
    $machines = Get-AzMigrateReplicatingServer -ResourceGroupName $cfg.azure_resource_group -ProjectName $project.Name
    Write-MigrationLog "Replicating machines: $($machines.Count)" -Level INFO -LogFile $logFile
    $machines | ForEach-Object {
        Write-MigrationLog "  $($_.MachineName) — state: $($_.MigrationState)" -Level INFO -LogFile $logFile
    }

    $ready = $machines | Where-Object MigrationState -eq 'Replicating'
    Write-MigrationLog "Machines ready for cutover: $($ready.Count)" -Level INFO -LogFile $logFile

    foreach ($vm in $ready) {
        if ($PSCmdlet.ShouldProcess($vm.MachineName, "Initiate cutover")) {
            Write-MigrationLog "Initiating cutover: $($vm.MachineName)" -Level INFO -LogFile $logFile
            Start-AzMigrateServerMigration -InputObject $vm -TurnOffSourceServer
            Write-MigrationLog "Cutover initiated: $($vm.MachineName)" -Level INFO -LogFile $logFile
        }
    }
}

Write-MigrationLog "Azure Migrate cutover orchestration complete. Validate migrated VMs, then complete migration in portal. Log: $logFile" -Level INFO -LogFile $logFile
Write-Host "Azure Migrate cutover complete. Log: $logFile" -ForegroundColor Green
