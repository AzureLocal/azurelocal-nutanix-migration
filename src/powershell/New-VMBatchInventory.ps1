#Requires -Version 5.1
<#
.SYNOPSIS
    Generates a batch inventory CSV/YAML from a source VM list.
    Reads VM names from a plain text file and produces config\variables\batches\batch-<n>.yml
    for consumption by Invoke-VeeamBatchCutover and Invoke-HYCUBackupRestore.

.PARAMETER ConfigPath
    Path to variables.yml. Defaults to config\variables\variables.yml relative to repo root.

.PARAMETER Credential
    PSCredential — not required for inventory generation, used when querying Nutanix Prism.

.PARAMETER TargetNode
    Nutanix Prism Element IP to query for live VM data. Defaults to config nutanix_prism_element_ip.

.PARAMETER LogPath
    Directory to write log files to. Defaults to logs\inventory\<timestamp>.log.

.PARAMETER BatchSize
    Number of VMs per batch. Defaults to config batch_size.

.PARAMETER WhatIf
    Show what batches would be created without writing files.

.EXAMPLE
    .\New-VMBatchInventory.ps1 -BatchSize 5 -Verbose

.NOTES
    Organization:  Infinite Improbability Corp (IIC)
    Idempotent:    Yes — overwrites existing batch files
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
    [int]$BatchSize,

    [Parameter()]
    [string]$LogPath
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\common\Config-Loader.ps1" -ConfigPath $ConfigPath

$cfg      = $script:MigrationConfig
$logFile  = Initialize-MigrationLog -TaskName 'inventory' -LogPath $LogPath
$cred     = Resolve-MigrationCredential -Credential $Credential -Username $cfg.nutanix_prism_username
$prismIP  = if ($TargetNode) { $TargetNode } else { $cfg.nutanix_prism_element_ip }
$size     = if ($BatchSize)  { $BatchSize  } else { $cfg.batch_size }
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent)

Write-MigrationLog "Inventory generation starting. Prism: $prismIP  BatchSize: $size" -Level INFO -LogFile $logFile

# ─── Query Nutanix Prism for VM list ─────────────────────────────────────────
$prismBase = "https://$($prismIP):9440/api/nutanix/v3"
$basicAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($cred.UserName):$($cred.GetNetworkCredential().Password)"))
$headers   = @{ Authorization = "Basic $basicAuth"; 'Content-Type' = 'application/json' }
$body      = '{"kind":"vm","length":500,"offset":0}' | ConvertFrom-Json | ConvertTo-Json

$vmList = @()
if ($PSCmdlet.ShouldProcess($prismIP, "Query Nutanix Prism for VM list")) {
    $resp   = Invoke-RestMethod -Uri "$prismBase/vms/list" -Method POST -Headers $headers -Body $body -SkipCertificateCheck
    $vmList = $resp.entities | Select-Object -ExpandProperty status | Select-Object -ExpandProperty name
    Write-MigrationLog "VMs retrieved from Prism: $($vmList.Count)" -Level INFO -LogFile $logFile
}

if ($vmList.Count -eq 0) {
    Write-MigrationLog "No VMs found. Exiting." -Level WARN -LogFile $logFile
    exit 0
}

# ─── Split into batches and write YAML ───────────────────────────────────────
$batchDir = Join-Path $repoRoot 'config\variables\batches'
$null = New-Item -ItemType Directory -Path $batchDir -Force

$batchNum  = 1
$batchVMs  = [System.Collections.Generic.List[string]]::new()

foreach ($vm in $vmList) {
    $batchVMs.Add($vm)
    if ($batchVMs.Count -ge $size) {
        $batchFile = Join-Path $batchDir ("batch-{0:D2}.yml" -f $batchNum)
        if ($PSCmdlet.ShouldProcess($batchFile, "Write batch")) {
            $content  = "# Batch $batchNum — generated $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`nvms:`n"
            $content += ($batchVMs | ForEach-Object { "  - $_" }) -join "`n"
            $content | Set-Content $batchFile -Encoding UTF8
            Write-MigrationLog "Batch $batchNum written: $batchFile ($($batchVMs.Count) VMs)" -Level INFO -LogFile $logFile
        }
        $batchNum++
        $batchVMs.Clear()
    }
}

# Remainder
if ($batchVMs.Count -gt 0) {
    $batchFile = Join-Path $batchDir ("batch-{0:D2}.yml" -f $batchNum)
    if ($PSCmdlet.ShouldProcess($batchFile, "Write final batch")) {
        $content  = "# Batch $batchNum — generated $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`nvms:`n"
        $content += ($batchVMs | ForEach-Object { "  - $_" }) -join "`n"
        $content | Set-Content $batchFile -Encoding UTF8
        Write-MigrationLog "Batch $batchNum written: $batchFile ($($batchVMs.Count) VMs)" -Level INFO -LogFile $logFile
    }
}

Write-MigrationLog "Inventory complete. $($batchNum) batch file(s) created in $batchDir. Log: $logFile" -Level INFO -LogFile $logFile
Write-Host "Inventory generation complete. Log: $logFile" -ForegroundColor Green
