resource "azurerm_virtual_network" "migration" {
  name                = "vnet-${var.environment}-migration-${var.resource_group_suffix}"
  location            = azurerm_resource_group.migration.location
  resource_group_name = azurerm_resource_group.migration.name
  address_space       = ["10.100.0.0/24"]
  tags                = local.tags
}

resource "azurerm_subnet" "migration" {
  name                 = "snet-migration"
  resource_group_name  = azurerm_resource_group.migration.name
  virtual_network_name = azurerm_virtual_network.migration.name
  address_prefixes     = ["10.100.0.0/27"]
}
