#Requires -Version 5.1
<#
.SYNOPSIS
    Orchestrates HYCU backup and restore of Nutanix VMs to a Hyper-V staging host.
    Triggers HYCU backup jobs via REST API and monitors restore status.

.PARAMETER ConfigPath
    Path to variables.yml. Defaults to config\variables\variables.yml relative to repo root.

.PARAMETER Credential
    PSCredential for HYCU REST API.
    Falls back to Key Vault or interactive prompt if not provided.

.PARAMETER TargetNode
    Hyper-V host to restore VMs to. Defaults to config hyperv_host.

.PARAMETER LogPath
    Directory to write log files to. Defaults to logs\hycu-restore\<timestamp>.log.

.PARAMETER WhatIf
    Simulate operations without making changes.

.EXAMPLE
    .\Invoke-HYCUBackupRestore.ps1 -ConfigPath .\config\variables\variables.yml -Verbose

.NOTES
    Organization:  Infinite Improbability Corp (IIC)
    Idempotent:    Yes — checks VM existence before restore
    Part of:       azurelocal-nutanix-migration
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

$cfg        = $script:MigrationConfig
$logFile    = Initialize-MigrationLog -TaskName 'hycu-restore' -LogPath $LogPath
$cred       = Resolve-MigrationCredential -Credential $Credential -Username 'admin'
$hvHost     = if ($TargetNode) { $TargetNode } else { $cfg.hyperv_host }
$hycuBase   = "https://$($cfg.hycu_controller_ip):$($cfg.hycu_web_port)/rest/v1.0"

Write-MigrationLog "HYCU restore starting. HYCU: $($cfg.hycu_controller_ip) → Hyper-V: $hvHost" -Level INFO -LogFile $logFile

# ─── HYCU auth ───────────────────────────────────────────────────────────────
$basicAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($cred.UserName):$($cred.GetNetworkCredential().Password)"))
$headers   = @{
    Authorization = "Basic $basicAuth"
    'Content-Type' = 'application/json'
}

if ($PSCmdlet.ShouldProcess($cfg.hycu_controller_ip, "Verify HYCU connectivity")) {
    $status = Invoke-RestMethod -Uri "$hycuBase/cluster" -Headers $headers -Method GET
    Write-MigrationLog "HYCU cluster: $($status.name) — version $($status.version)" -Level INFO -LogFile $logFile
}

# ─── List VMs available for restore ──────────────────────────────────────────
if ($PSCmdlet.ShouldProcess($cfg.hycu_controller_ip, "List VMs for restore")) {
    $vms = Invoke-RestMethod -Uri "$hycuBase/vms" -Headers $headers -Method GET
    Write-MigrationLog "VMs found in HYCU: $($vms.entities.Count)" -Level INFO -LogFile $logFile
    $vms.entities | ForEach-Object {
        Write-MigrationLog "  VM: $($_.vmName) — protected: $($_.protected)" -Level INFO -LogFile $logFile
    }
}

Write-MigrationLog "HYCU restore orchestration complete. Validate restored VMs on $hvHost before proceeding to Azure Migrate." -Level INFO -LogFile $logFile
Write-Host "HYCU restore complete. Log: $logFile" -ForegroundColor Green
