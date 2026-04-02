# PowerShell Automation — Nutanix to Azure Local Migration

PowerShell scripts for orchestrating the full migration pipeline from Nutanix (AHV/ESXi) to Azure Local.

## Structure

```
powershell/
├── common/
│   ├── CanonicalVariable.psm1   # Shared module: config load, credential resolve, logging
│   └── Config-Loader.ps1        # Bootstrap: auto-creates variables.yml from example if missing
├── Invoke-MigrationPreflight.ps1  # Pre-flight environment checks
├── New-VMBatchInventory.ps1       # Query Nutanix Prism and build batch YAML files
├── Invoke-VeeamBatchCutover.ps1   # Veeam replica finalization and cutover (Hop 1)
├── Invoke-HYCUBackupRestore.ps1   # HYCU backup trigger and restore to Hyper-V (Hop 1)
├── Set-VMNetworkConfig.ps1        # Re-IP VMs post-restore using ip-mapping.yml
├── Invoke-AzureMigrateCutover.ps1 # Azure Migrate replication and cutover (Hop 2)
├── Test-MigrationValidation.ps1   # Post-migration health validation
└── parameters.example.ps1         # Example parameter file with usage examples
```

## Prerequisites

- PowerShell 5.1 or PowerShell 7+
- `powershell-yaml` module: `Install-Module powershell-yaml -Scope CurrentUser`
- Azure PowerShell modules for Azure Migrate steps: `Install-Module Az -Scope CurrentUser`
- WinRM access to Hyper-V staging host
- Veeam REST API access (port 9419)
- HYCU REST API access (port 8443 by default)

## Quick Start

1. Copy `config\examples\variables.example.yml` → `config\variables\variables.yml`
2. Populate `variables.yml` with your environment values
3. Run preflight:

```powershell
cd src\powershell
.\Invoke-MigrationPreflight.ps1 -Verbose
```

4. Generate batch inventory from Nutanix Prism:

```powershell
.\New-VMBatchInventory.ps1 -BatchSize 10 -Verbose
```

5. Run migration per your chosen path (Veeam or HYCU), then Azure Migrate cutover.

## Naming Conventions

All scripts follow org-standard `Verb-Noun.ps1` naming:

| Prefix | Usage |
|--------|-------|
| `Invoke-` | Triggers an action (cutover, restore, backup) — requires `-ConfigPath -Credential -TargetNode -WhatIf -LogPath` |
| `Set-`    | Applies configuration state to a resource |
| `Test-`   | Read-only validation, returns pass/fail results |
| `New-`    | Creates new resources or data files |

## Credential Handling

Credentials are resolved in this order:

1. `-Credential` parameter (if provided)
2. Azure Key Vault (`kv-iic-migration`) via `-KeyVaultName` / `-SecretName`
3. Interactive `Get-Credential` prompt

Never store plain-text passwords in scripts or config files.

## Logging

All scripts write logs to `logs\<task-name>\<timestamp>.log` relative to the repo root.
Override with `-LogPath`.
