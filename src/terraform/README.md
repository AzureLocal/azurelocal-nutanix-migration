# Terraform — Nutanix to Azure Local Migration

Terraform configuration for deploying the Azure infrastructure required to support
migration from Nutanix (AHV/ESXi) to Azure Local.

## Resources Deployed

| Resource | Name |
|----------|------|
| Resource Group | `rg-iic-migration-01` |
| Key Vault | `kv-iic-migration` |
| Virtual Network | `vnet-iic-migration-01` |
| Azure Migrate Project | `migrate-iic-nutanix-01` |

## Prerequisites

- Terraform >= 1.5
- Azure CLI authenticated: `az login`
- Contributor + Key Vault Administrator on target subscription

## Usage

```bash
# 1. Copy and populate variables
cp terraform.tfvars.example terraform.tfvars

# 2. Initialize
terraform init

# 3. Plan
terraform plan -var-file="terraform.tfvars"

# 4. Apply
terraform apply -var-file="terraform.tfvars"
```

## Provider Versions

| Provider | Version |
|----------|---------|
| `hashicorp/azurerm` | `>= 4.0` |
| `azure/azapi`       | `>= 1.10` |

## State

Store state remotely in Azure Storage for team use:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-iic-tfstate"
    storage_account_name = "stiictfstate01"
    container_name       = "tfstate"
    key                  = "nutanix-migration.terraform.tfstate"
  }
}
```
