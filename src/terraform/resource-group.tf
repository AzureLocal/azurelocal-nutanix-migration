resource "azurerm_resource_group" "migration" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}
