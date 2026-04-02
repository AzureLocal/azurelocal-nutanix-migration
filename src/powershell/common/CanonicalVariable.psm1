#Requires -Version 5.1
<#
.SYNOPSIS
    Canonical variable module for Nutanix to Azure Local migration automation.
    Provides shared config loading, variable resolution, and common helpers.

.NOTES
    Organization: Infinite Improbability Corp (IIC)
    Module: CanonicalVariable.psm1
    Part of: azurelocal-nutanix-migration
#>

# ─────────────────────────────────────────────────────────────────────────────
# Region: Config resolution
# ─────────────────────────────────────────────────────────────────────────────

function Get-MigrationConfig {
    <#
    .SYNOPSIS
        Load and return the migration config from variables.yml.
    .PARAMETER ConfigPath
        Path to the variables.yml file. Defaults to config/variables/variables.yml
        relative to the repo root.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ConfigPath
    )

    if (-not $ConfigPath) {
        $repoRoot   = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
        $ConfigPath = Join-Path $repoRoot 'config\variables\variables.yml'
    }

    if (-not (Test-Path $ConfigPath)) {
        $examplePath = $ConfigPath -replace 'variables\.yml$', '..\..\examples\variables.example.yml'
        if (Test-Path $examplePath) {
            Write-Warning "variables.yml not found. Copying example to '$ConfigPath' — fill in real values before running."
            Copy-Item $examplePath $ConfigPath
        } else {
            throw "Config file not found: $ConfigPath — copy config\examples\variables.example.yml to config\variables\variables.yml and populate."
        }
    }

    # Requires powershell-yaml or yq. Fall back to ordered hashtable parse if available.
    if (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue) {
        return Get-Content $ConfigPath -Raw | ConvertFrom-Yaml
    }

    throw "ConvertFrom-Yaml not available. Install the 'powershell-yaml' module: Install-Module powershell-yaml -Scope CurrentUser"
}

# ─────────────────────────────────────────────────────────────────────────────
# Region: Credential resolution
# ─────────────────────────────────────────────────────────────────────────────

function Resolve-MigrationCredential {
    <#
    .SYNOPSIS
        Resolve credentials in order: parameter → Key Vault → interactive prompt.
    .PARAMETER Credential
        PSCredential provided directly by the caller.
    .PARAMETER KeyVaultName
        Azure Key Vault name to retrieve credential from.
    .PARAMETER SecretName
        Key Vault secret name for the password.
    .PARAMETER Username
        Username for interactive prompt fallback.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCredential]$Credential,

        [Parameter()]
        [string]$KeyVaultName,

        [Parameter()]
        [string]$SecretName,

        [Parameter()]
        [string]$Username = 'administrator'
    )

    if ($Credential) { return $Credential }

    if ($KeyVaultName -and $SecretName) {
        try {
            $secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -AsPlainText
            return [PSCredential]::new($Username, (ConvertTo-SecureString $secret -AsPlainText -Force))
        } catch {
            Write-Warning "Key Vault retrieval failed: $_"
        }
    }

    return Get-Credential -UserName $Username -Message "Enter migration credentials"
}

# ─────────────────────────────────────────────────────────────────────────────
# Region: Logging
# ─────────────────────────────────────────────────────────────────────────────

function Initialize-MigrationLog {
    <#
    .SYNOPSIS
        Create a log file for the current task run and return the path.
    .PARAMETER TaskName
        Short label used in the log path, e.g. "preflight" or "veeam-cutover".
    .PARAMETER LogPath
        Override default log directory.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TaskName,

        [Parameter()]
        [string]$LogPath
    )

    if (-not $LogPath) {
        $repoRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent
        $LogPath  = Join-Path $repoRoot "logs\$TaskName"
    }

    $null = New-Item -ItemType Directory -Path $LogPath -Force
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    return Join-Path $LogPath "$timestamp.log"
}

function Write-MigrationLog {
    <#
    .SYNOPSIS
        Write a timestamped log entry to a log file and the console.
    .PARAMETER Message
        Log message text.
    .PARAMETER Level
        INFO | WARN | ERROR
    .PARAMETER LogFile
        Path to the log file returned by Initialize-MigrationLog.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string]$Message,
        [Parameter()] [ValidateSet('INFO','WARN','ERROR')] [string]$Level = 'INFO',
        [Parameter()] [string]$LogFile
    )

    $entry = "[{0}] [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message

    switch ($Level) {
        'WARN'  { Write-Warning $Message }
        'ERROR' { Write-Error   $Message }
        default { Write-Verbose $Message }
    }

    if ($LogFile) { $entry | Out-File -FilePath $LogFile -Append -Encoding UTF8 }
}

Export-ModuleMember -Function Get-MigrationConfig, Resolve-MigrationCredential, Initialize-MigrationLog, Write-MigrationLog
