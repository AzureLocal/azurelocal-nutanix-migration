# Bicep — Nutanix to Azure Local Migration

Bicep templates for deploying migration infrastructure.
Subscription-scoped: creates the resource group and all resources within it.

## Structure

```
bicep/
├── main.bicep                   # Entry point (subscription scope)
├── main.bicepparam.example      # Example parameter file — copy and populate
├── Deploy-MigrationInfra.ps1   # Deployment orchestrator script
└── modules/
    ├── resource-group.bicep
    ├── keyvault.bicep
    └── azure-migrate.bicep
```

## Usage

```powershell
# 1. Copy and populate the param file
cp main.bicepparam.example main.bicepparam

# 2. Deploy
.\Deploy-MigrationInfra.ps1 -ParamFile .\main.bicepparam -Verbose

# 3. What-if (dry run)
.\Deploy-MigrationInfra.ps1 -ParamFile .\main.bicepparam -WhatIf -Verbose
```

Or via Azure CLI directly:

```bash
az deployment sub create \
  --location eastus \
  --template-file main.bicep \
  --parameters main.bicepparam \
  --subscription 00000000-0000-0000-0000-000000000000
```

## Prerequisites

- Azure CLI >= 2.50 with Bicep built-in
- Contributor role on the target subscription
- PowerShell 5.1+ (for `Deploy-MigrationInfra.ps1`)
