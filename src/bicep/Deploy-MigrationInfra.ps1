#Requires -Version 5.1
<#
.SYNOPSIS
    Orchestrates deployment of Bicep infrastructure for Nutanix to Azure Local migration.

.PARAMETER ConfigPath
    Path to variables.yml. Defaults to config\variables\variables.yml.

.PARAMETER ParamFile
    Path to main.bicepparam (must exist — copy from main.bicepparam.example and populate).

.PARAMETER WhatIf
    Run az deployment in what-if mode without making changes.

.EXAMPLE
    .\Deploy-MigrationInfra.ps1 -ParamFile .\main.bicepparam -Verbose

.NOTES
    Organization: Infinite Improbability Corp (IIC)
    Part of:      azurelocal-nutanix-migration
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter()]
    [string]$ConfigPath,

    [Parameter()]
    [string]$ParamFile = "$PSScriptRoot\main.bicepparam",

    [Parameter()]
    [string]$LogPath
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\..\powershell\common\Config-Loader.ps1" -ConfigPath $ConfigPath

$cfg     = $script:MigrationConfig
$logFile = Initialize-MigrationLog -TaskName 'bicep-deploy' -LogPath $LogPath

if (-not (Test-Path $ParamFile)) {
    Write-Warning "Parameter file not found: $ParamFile"
    Write-Warning "Copy main.bicepparam.example to main.bicepparam and populate with your values."
    exit 1
}

if ($PSCmdlet.ShouldProcess("subscription: $($cfg.azure_subscription_id)", "Deploy Bicep template")) {
    Write-MigrationLog "Deploying Bicep to subscription: $($cfg.azure_subscription_id)" -Level INFO -LogFile $logFile

    $deployArgs = @(
        'deployment', 'sub', 'create',
        '--location', $cfg.azure_location,
        '--template-file', "$PSScriptRoot\main.bicep",
        '--parameters', $ParamFile,
        '--subscription', $cfg.azure_subscription_id,
        '--name', "nutanix-migration-$(Get-Date -Format 'yyyyMMddHHmmss')"
    )

    if ($WhatIfPreference) {
        $deployArgs[2] = 'what-if'
        Write-MigrationLog "Running in what-if mode" -Level WARN -LogFile $logFile
    }

    & az @deployArgs
    if ($LASTEXITCODE -ne 0) {
        Write-MigrationLog "Bicep deployment failed (exit $LASTEXITCODE)" -Level ERROR -LogFile $logFile
        exit $LASTEXITCODE
    }
    Write-MigrationLog "Bicep deployment complete. Log: $logFile" -Level INFO -LogFile $logFile
}

Write-Host "Deployment complete. Log: $logFile" -ForegroundColor Green
