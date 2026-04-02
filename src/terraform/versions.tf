terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.10"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy                            = false
      recover_soft_deleted_key_vaults                         = true
      recover_soft_deleted_certificates                       = true
      recover_soft_deleted_keys                               = true
      recover_soft_deleted_secrets                            = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {}
