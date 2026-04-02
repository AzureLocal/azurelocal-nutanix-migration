#Requires -Version 5.1
<#
.SYNOPSIS
    Pre-migration environment validation for Nutanix to Azure Local migration.
    Validates connectivity to all required services before any migration activity begins.

.PARAMETER ConfigPath
    Path to variables.yml. Defaults to config\variables\variables.yml relative to repo root.

.PARAMETER Credential
    PSCredential for authenticating to Hyper-V and Veeam/HYCU hosts.
    Falls back to Key Vault or interactive prompt if not provided.

.PARAMETER TargetNode
    Specific node or host to run preflight against. Defaults to all nodes in config.

.PARAMETER LogPath
    Directory to write log files to. Defaults to logs\preflight\<timestamp>.log.

.PARAMETER WhatIf
    Show what checks would run without executing them.

.EXAMPLE
    .\Invoke-MigrationPreflight.ps1 -ConfigPath .\config\variables\variables.yml -Verbose

.NOTES
    Organization:  Infinite Improbability Corp (IIC)
    Idempotent:    Yes — read-only checks only
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

# ─── Bootstrap ───────────────────────────────────────────────────────────────
. "$PSScriptRoot\common\Config-Loader.ps1" -ConfigPath $ConfigPath
$cfg    = $script:MigrationConfig
$logFile = Initialize-MigrationLog -TaskName 'preflight' -LogPath $LogPath
$cred   = Resolve-MigrationCredential -Credential $Credential -Username 'administrator'

Write-MigrationLog "Starting migration preflight for environment: $($cfg.environment)" -Level INFO -LogFile $logFile

# ─── Helper: test TCP port ────────────────────────────────────────────────────
function Test-TcpPort {
    param([string]$Host, [int]$Port, [int]$TimeoutMs = 3000)
    try {
        $tcp = [System.Net.Sockets.TcpClient]::new()
        $ar  = $tcp.BeginConnect($Host, $Port, $null, $null)
        $ok  = $ar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        $tcp.Close()
        return $ok
    } catch { return $false }
}

$results = [System.Collections.Generic.List[PSCustomObject]]::new()

# ─── 1. DNS resolution ────────────────────────────────────────────────────────
$hosts = @(
    $cfg.hyperv_host,
    $cfg.veeam_server,
    $cfg.hycu_controller_ip,
    $cfg.nutanix_prism_element_ip,
    $cfg.azlocal_cluster
) | Where-Object { $_ }

foreach ($h in $hosts) {
    if ($PSCmdlet.ShouldProcess($h, "Test-NetConnection DNS")) {
        try {
            $null = [System.Net.Dns]::GetHostEntry($h)
            $results.Add([PSCustomObject]@{ Check = "DNS: $h"; Status = 'PASS'; Detail = '' })
            Write-MigrationLog "DNS OK: $h" -Level INFO -LogFile $logFile
        } catch {
            $results.Add([PSCustomObject]@{ Check = "DNS: $h"; Status = 'FAIL'; Detail = $_.Exception.Message })
            Write-MigrationLog "DNS FAIL: $h — $($_.Exception.Message)" -Level WARN -LogFile $logFile
        }
    }
}

# ─── 2. Port connectivity ─────────────────────────────────────────────────────
$portChecks = @(
    @{ Host = $cfg.hyperv_host;          Port = 5985;  Label = 'Hyper-V WinRM'       }
    @{ Host = $cfg.veeam_server;         Port = 9392;  Label = 'Veeam REST API'       }
    @{ Host = $cfg.hycu_controller_ip;   Port = $cfg.hycu_web_port; Label = 'HYCU Web' }
    @{ Host = $cfg.nutanix_prism_element_ip; Port = 9440; Label = 'Nutanix Prism'    }
) | Where-Object { $_['Host'] }

foreach ($check in $portChecks) {
    if ($PSCmdlet.ShouldProcess("$($check.Host):$($check.Port)", "Test TCP port")) {
        $ok = Test-TcpPort -Host $check.Host -Port $check.Port
        $status = if ($ok) { 'PASS' } else { 'FAIL' }
        $results.Add([PSCustomObject]@{ Check = "$($check.Label) ($($check.Host):$($check.Port))"; Status = $status; Detail = '' })
        Write-MigrationLog "$status — $($check.Label) at $($check.Host):$($check.Port)" -Level $(if ($ok) { 'INFO' } else { 'WARN' }) -LogFile $logFile
    }
}

# ─── 3. Hyper-V staging path ─────────────────────────────────────────────────
if ($cfg.hyperv_staging_path -and $cfg.hyperv_host) {
    $uncPath = "\\$($cfg.hyperv_host)\$(($cfg.hyperv_staging_path -replace ':','$').TrimStart('\'))"
    if ($PSCmdlet.ShouldProcess($uncPath, "Test staging path")) {
        $ok = Test-Path $uncPath -ErrorAction SilentlyContinue
        $status = if ($ok) { 'PASS' } else { 'WARN' }
        $results.Add([PSCustomObject]@{ Check = "Staging path: $uncPath"; Status = $status; Detail = if (-not $ok) { 'Path not reachable — verify Hyper-V SMB share' } else { '' } })
        Write-MigrationLog "$status — Staging path $uncPath" -Level $status -LogFile $logFile
    }
}

# ─── Summary ─────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "Preflight Results" -ForegroundColor Cyan
$results | Format-Table Check, Status, Detail -AutoSize

$failures = $results | Where-Object Status -eq 'FAIL'
if ($failures) {
    Write-MigrationLog "Preflight FAILED — $($failures.Count) check(s) failed. Review log: $logFile" -Level ERROR -LogFile $logFile
    exit 1
}

Write-MigrationLog "Preflight complete. All critical checks passed. Log: $logFile" -Level INFO -LogFile $logFile
Write-Host "Preflight complete." -ForegroundColor Green
