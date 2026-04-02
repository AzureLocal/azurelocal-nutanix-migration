variable "location" {
  description = "Azure region for all migration resources."
  type        = string
  default     = "eastus"
}

variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Short environment label used in resource names (e.g. 'iic')."
  type        = string
  default     = "iic"
}

variable "resource_group_suffix" {
  description = "Suffix appended to the migration resource group name."
  type        = string
  default     = "01"
}

variable "key_vault_name" {
  description = "Name of the Key Vault used to store migration credentials."
  type        = string
  default     = "kv-iic-migration"
}

variable "migrate_project_name" {
  description = "Name of the Azure Migrate project."
  type        = string
  default     = "migrate-iic-nutanix-01"
}

variable "azlocal_cluster_name" {
  description = "Name of the Azure Local cluster target."
  type        = string
  default     = "azlocal-iic-01"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
