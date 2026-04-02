#Requires -Version 5.1
<#
.SYNOPSIS
    Bootstrap script — locate and load variables.yml, then import CanonicalVariable.psm1.
    Source this script at the top of any Invoke-*.ps1 script in this repository.

.EXAMPLE
    . "$PSScriptRoot\..\common\Config-Loader.ps1" -ConfigPath $ConfigPath

.NOTES
    Organization: Infinite Improbability Corp (IIC)
    Part of: azurelocal-nutanix-migration
#>
param (
    [Parameter()]
    [string]$ConfigPath
)

$ErrorActionPreference = 'Stop'

# ─── Import shared module ────────────────────────────────────────────────────
$modulePath = Join-Path $PSScriptRoot 'CanonicalVariable.psm1'
if (-not (Test-Path $modulePath)) {
    throw "CanonicalVariable.psm1 not found at: $modulePath"
}
Import-Module $modulePath -Force

# ─── Bootstrap: auto-create variables.yml from example if missing ────────────
if (-not $ConfigPath) {
    $repoRoot   = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $ConfigPath = Join-Path $repoRoot 'config\variables\variables.yml'
}

if (-not (Test-Path $ConfigPath)) {
    $examplePath = Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent) 'config\examples\variables.example.yml'
    if (Test-Path $examplePath) {
        Write-Warning "variables.yml not found. Creating from example at: $ConfigPath"
        Write-Warning "Fill in real environment values before running migration scripts."
        Copy-Item $examplePath $ConfigPath
    } else {
        throw "Config not found and example not available. Expected: $ConfigPath"
    }
}

# ─── Load config into caller scope ───────────────────────────────────────────
$script:MigrationConfig = Get-MigrationConfig -ConfigPath $ConfigPath
Write-Verbose "Config loaded: $ConfigPath (environment: $($script:MigrationConfig.environment))"
