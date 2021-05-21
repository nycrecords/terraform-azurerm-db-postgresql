data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

module "azure-region" {
  source = "github.com/nycrecords/infrastructure-modules.git//terraform-azurerm-regions"
  azure_region = data.azurerm_resource_group.rg.location
}

locals {
  name_prefix  = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]$/", "$0-") : ""
  default_name = lower("${local.name_prefix}-${module.azure_region.location_short}-${var.environment}")

  postgresql_server_name = coalesce(var.custom_server_name, "${local.default_name}-postgresql")

  default_tags = {
    env   = var.environment
  }

  tier_map = {
    "GeneralPurpose"  = "GP"
    "Basic"           = "B"
    "MemoryOptimized" = "MO"
  }
}
