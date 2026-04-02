locals {
  resource_group_name = "rg-${var.environment}-migration-${var.resource_group_suffix}"

  default_tags = {
    environment = var.environment
    project     = "nutanix-migration"
    managed_by  = "terraform"
    org         = "iic"
  }

  tags = merge(local.default_tags, var.tags)
}
