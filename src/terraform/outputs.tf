output "resource_group_name" {
  description = "Migration resource group name."
  value       = azurerm_resource_group.migration.name
}

output "resource_group_id" {
  description = "Migration resource group resource ID."
  value       = azurerm_resource_group.migration.id
}

output "key_vault_name" {
  description = "Key Vault name."
  value       = azurerm_key_vault.migration.name
}

output "key_vault_uri" {
  description = "Key Vault URI for secret retrieval."
  value       = azurerm_key_vault.migration.vault_uri
}

output "migrate_project_name" {
  description = "Azure Migrate project name."
  value       = azurerm_migrate_project.migration.name
}

output "vnet_name" {
  description = "Migration virtual network name."
  value       = azurerm_virtual_network.migration.name
}
