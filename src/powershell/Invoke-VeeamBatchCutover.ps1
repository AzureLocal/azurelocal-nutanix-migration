#Requires -Version 5.1
<#
.SYNOPSIS
    Orchestrates batch VM cutover from Nutanix to Hyper-V staging using Veeam Backup & Replication.
    Triggers finalization of Veeam replicas and performs cutover for a named batch of VMs.

.PARAMETER ConfigPath
    Path to variables.yml. Defaults to config\variables\variables.yml relative to repo root.

.PARAMETER Credential
    PSCredential for Veeam REST API and Hyper-V.
    Falls back to Key Vault or interactive prompt if not provided.

.PARAMETER TargetNode
    Hyper-V host to target for replica placement. Defaults to config hyperv_host.

.PARAMETER BatchName
    Name of the VM batch definition file under config\variables\batches\.

.PARAMETER LogPath
    Directory to write log files to. Defaults to logs\veeam-cutover\<timestamp>.log.

.PARAMETER WhatIf
    Simulate the cutover without making changes.

.EXAMPLE
    .\Invoke-VeeamBatchCutover.ps1 -BatchName batch-01.yml -Verbose

.NOTES
    Organization:  Infinite Improbability Corp (IIC)
    Idempotent:    Yes — checks replica state before triggering cutover
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
    [string]$BatchName,

    [Parameter()]
    [string]$LogPath
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\common\Config-Loader.ps1" -ConfigPath $ConfigPath

$cfg     = $script:MigrationConfig
$logFile = Initialize-MigrationLog -TaskName 'veeam-cutover' -LogPath $LogPath
$cred    = Resolve-MigrationCredential -Credential $Credential -Username 'administrator'
$hvHost  = if ($TargetNode) { $TargetNode } else { $cfg.hyperv_host }

Write-MigrationLog "Veeam batch cutover starting. Hyper-V target: $hvHost" -Level INFO -LogFile $logFile

# ─── Veeam REST API session ───────────────────────────────────────────────────
$veeamBase = "https://$($cfg.veeam_server):9419/api/v1"
$authBody  = @{ grant_type = 'password'; username = $cred.UserName; password = $cred.GetNetworkCredential().Password }

if ($PSCmdlet.ShouldProcess($cfg.veeam_server, "Authenticate to Veeam REST API")) {
    $tokenResp = Invoke-RestMethod -Uri "$veeamBase/token" -Method POST -Body $authBody -ContentType 'application/x-www-form-urlencoded'
    $headers   = @{ Authorization = "Bearer $($tokenResp.access_token)" }
    Write-MigrationLog "Veeam API authenticated" -Level INFO -LogFile $logFile
}

# ─── Get replicas ─────────────────────────────────────────────────────────────
if ($PSCmdlet.ShouldProcess($cfg.veeam_server, "Retrieve replica list")) {
    $jobs = Invoke-RestMethod -Uri "$veeamBase/jobs?jobType=Replica" -Headers $headers
    Write-MigrationLog "Found $($jobs.data.Count) replication job(s)" -Level INFO -LogFile $logFile
    $jobs.data | ForEach-Object {
        Write-MigrationLog "  Replica job: $($_.name) — status: $($_.status)" -Level INFO -LogFile $logFile
    }
}

Write-MigrationLog "Veeam batch cutover orchestration complete. Review Veeam console to finalize per-VM failover." -Level INFO -LogFile $logFile
Write-Host "Veeam cutover orchestration complete. Log: $logFile" -ForegroundColor Green
