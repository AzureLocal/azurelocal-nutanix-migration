resource "azurerm_migrate_project" "migration" {
  name                = var.migrate_project_name
  resource_group_name = azurerm_resource_group.migration.name
  location            = azurerm_resource_group.migration.location
  tags                = local.tags
}
