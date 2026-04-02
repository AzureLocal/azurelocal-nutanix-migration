data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "migration" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.migration.location
  resource_group_name         = azurerm_resource_group.migration.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
  tags                        = local.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

# Grant the deploying principal Key Vault Secrets Officer role
resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.migration.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
