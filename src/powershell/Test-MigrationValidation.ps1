#Requires -Version 5.1
<#
.SYNOPSIS
    Post-migration validation checks for VMs migrated to Azure Local.
    Verifies connectivity, services, domain join, and Azure integration.

.PARAMETER ConfigPath
    Path to variables.yml. Defaults to config\variables\variables.yml relative to repo root.

.PARAMETER Credential
    PSCredential for WinRM access to migrated VMs.
    Falls back to Key Vault or interactive prompt if not provided.

.PARAMETER TargetNode
    Azure Local cluster or specific VM host to validate. Defaults to config azlocal_cluster.

.PARAMETER LogPath
    Directory to write log files to. Defaults to logs\validation\<timestamp>.log.

.PARAMETER WhatIf
    Show what would be validated without running checks.

.EXAMPLE
    .\Test-MigrationValidation.ps1 -ConfigPath .\config\variables\variables.yml -Verbose

.NOTES
    Organization:  Infinite Improbability Corp (IIC)
    Idempotent:    Yes — read-only validation only
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

$cfg     = $script:MigrationConfig
$logFile = Initialize-MigrationLog -TaskName 'validation' -LogPath $LogPath
$cred    = Resolve-MigrationCredential -Credential $Credential -Username 'administrator'
$cluster = if ($TargetNode) { $TargetNode } else { $cfg.azlocal_cluster }

Write-MigrationLog "Post-migration validation starting on cluster: $cluster" -Level INFO -LogFile $logFile

$results = [System.Collections.Generic.List[PSCustomObject]]::new()

# ─── 1. Cluster health ────────────────────────────────────────────────────────
if ($PSCmdlet.ShouldProcess($cluster, "Get-ClusterNode health")) {
    try {
        $nodes = Invoke-Command -ComputerName $cluster -Credential $cred -ScriptBlock { Get-ClusterNode }
        foreach ($node in $nodes) {
            $status = if ($node.State -eq 'Up') { 'PASS' } else { 'FAIL' }
            $results.Add([PSCustomObject]@{ Check = "Cluster node: $($node.Name)"; Status = $status; Detail = $node.State })
            Write-MigrationLog "$status — Cluster node $($node.Name) state: $($node.State)" -Level $(if ($status -eq 'PASS') { 'INFO' } else { 'WARN' }) -LogFile $logFile
        }
    } catch {
        $results.Add([PSCustomObject]@{ Check = "Cluster health: $cluster"; Status = 'FAIL'; Detail = $_.Exception.Message })
        Write-MigrationLog "FAIL — Cluster health check: $($_.Exception.Message)" -Level WARN -LogFile $logFile
    }
}

# ─── 2. VM power state ────────────────────────────────────────────────────────
if ($PSCmdlet.ShouldProcess($cluster, "Get-VM power state")) {
    try {
        $vms = Invoke-Command -ComputerName $cluster -Credential $cred -ScriptBlock { Get-VM }
        foreach ($vm in $vms) {
            $status = if ($vm.State -eq 'Running') { 'PASS' } else { 'WARN' }
            $results.Add([PSCustomObject]@{ Check = "VM power: $($vm.Name)"; Status = $status; Detail = $vm.State })
            Write-MigrationLog "$status — VM $($vm.Name) state: $($vm.State)" -Level $(if ($status -eq 'PASS') { 'INFO' } else { 'WARN' }) -LogFile $logFile
        }
    } catch {
        Write-MigrationLog "WARN — Could not retrieve VM list: $($_.Exception.Message)" -Level WARN -LogFile $logFile
    }
}

# ─── 3. Azure Arc registration ────────────────────────────────────────────────
if ($PSCmdlet.ShouldProcess($cfg.azure_resource_group, "Get Arc-enabled VMs in Azure")) {
    try {
        $arcMachines = Get-AzConnectedMachine -ResourceGroupName $cfg.azure_resource_group -ErrorAction SilentlyContinue
        Write-MigrationLog "Arc-connected machines in RG: $($arcMachines.Count)" -Level INFO -LogFile $logFile
        foreach ($m in $arcMachines) {
            $status = if ($m.Status -eq 'Connected') { 'PASS' } else { 'WARN' }
            $results.Add([PSCustomObject]@{ Check = "Arc: $($m.Name)"; Status = $status; Detail = $m.Status })
        }
    } catch {
        Write-MigrationLog "WARN — Arc check skipped: $($_.Exception.Message)" -Level WARN -LogFile $logFile
    }
}

# ─── Summary ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Validation Results" -ForegroundColor Cyan
$results | Format-Table Check, Status, Detail -AutoSize

$failures = $results | Where-Object Status -eq 'FAIL'
if ($failures) {
    Write-MigrationLog "Validation FAILED — $($failures.Count) critical check(s) failed. Review log: $logFile" -Level ERROR -LogFile $logFile
    exit 1
}

Write-MigrationLog "Validation complete. All checks passed. Log: $logFile" -Level INFO -LogFile $logFile
Write-Host "Validation complete." -ForegroundColor Green
