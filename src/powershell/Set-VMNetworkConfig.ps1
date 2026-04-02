#Requires -Version 5.1
<#
.SYNOPSIS
    Reconfigures VM network adapters after restore to Hyper-V staging host.
    Sets static IP, subnet mask, gateway, and DNS per the IP mapping in config.

.PARAMETER ConfigPath
    Path to variables.yml. Defaults to config\variables\variables.yml relative to repo root.

.PARAMETER Credential
    PSCredential for connecting to the target VM (WinRM).
    Falls back to Key Vault or interactive prompt if not provided.

.PARAMETER TargetNode
    Hyper-V host where the restored VMs reside. Defaults to config hyperv_host.

.PARAMETER LogPath
    Directory to write log files to. Defaults to logs\reip\<timestamp>.log.

.PARAMETER WhatIf
    Simulate network changes without applying them.

.EXAMPLE
    .\Set-VMNetworkConfig.ps1 -ConfigPath .\config\variables\variables.yml -TargetNode hyperv-staging.iic.local -Verbose

.NOTES
    Organization:  Infinite Improbability Corp (IIC)
    Idempotent:    Yes — checks current IP before applying
    Part of:       azurelocal-nutanix-migration
    IP Mapping:    Define per-VM entries in config\variables\ip-mapping.yml
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
$logFile = Initialize-MigrationLog -TaskName 'reip' -LogPath $LogPath
$cred    = Resolve-MigrationCredential -Credential $Credential -Username 'administrator'
$hvHost  = if ($TargetNode) { $TargetNode } else { $cfg.hyperv_host }

Write-MigrationLog "Re-IP starting on Hyper-V host: $hvHost" -Level INFO -LogFile $logFile

# ─── Load IP mapping ─────────────────────────────────────────────────────────
$repoRoot       = Split-Path (Split-Path $PSScriptRoot -Parent)
$ipMappingPath  = Join-Path $repoRoot 'config\variables\ip-mapping.yml'

if (-not (Test-Path $ipMappingPath)) {
    Write-MigrationLog "IP mapping file not found: $ipMappingPath — create this file with per-VM network assignments." -Level WARN -LogFile $logFile
    Write-Warning "No ip-mapping.yml found. Exiting without changes."
    exit 0
}

$ipMapping = Get-Content $ipMappingPath -Raw | ConvertFrom-Yaml

foreach ($entry in $ipMapping.vms) {
    $vmName = $entry.name
    $newIP  = $entry.new_ip
    $mask   = $entry.subnet_mask
    $gw     = $entry.gateway

    if ($PSCmdlet.ShouldProcess($vmName, "Set network config to $newIP")) {
        Write-MigrationLog "Configuring $vmName → IP: $newIP  Mask: $mask  GW: $gw" -Level INFO -LogFile $logFile

        Invoke-Command -ComputerName $hvHost -Credential $cred -ScriptBlock {
            param($vmName, $newIP, $mask, $gw, $dns)
            $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object Status -eq 'Up' | Select-Object -First 1
            if (-not $adapter) { throw "No active adapter found in $vmName" }
            $current = ($adapter | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
            if ($current -eq $newIP) {
                Write-Host "$vmName already has IP $newIP — skipping"
                return
            }
            $adapter | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue
            $adapter | Remove-NetRoute -Confirm:$false -ErrorAction SilentlyContinue
            $adapter | New-NetIPAddress -IPAddress $newIP -PrefixLength (([Convert]::ToString([IPAddress]::Parse($mask).Address, 2)).Replace('0','').Length) -DefaultGateway $gw
            Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $dns
            Write-Host "$vmName configured: $newIP"
        } -ArgumentList $vmName, $newIP, $mask, $gw, ($cfg.dns_servers -join ',') @hmParam
    }
}

Write-MigrationLog "Re-IP complete. Log: $logFile" -Level INFO -LogFile $logFile
Write-Host "Re-IP complete. Log: $logFile" -ForegroundColor Green
