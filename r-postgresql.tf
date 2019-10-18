resource "azurerm_postgresql_server" "postgresql_server" {
  name = coalesce(
    var.custom_server_name,
    "${var.stack}-${var.client_name}-${var.location_short}-${var.environment}-postgresql",
  )
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    capacity = lookup(var.server_sku, "capacity", null)
    family   = lookup(var.server_sku, "family", null)
    name     = lookup(var.server_sku, "name", null)
    tier     = lookup(var.server_sku, "tier", null)
  }

  storage_profile {
    storage_mb            = lookup(var.server_storage_profile, "storage_mb", null)
    backup_retention_days = lookup(var.server_storage_profile, "backup_retention_days", null)
    geo_redundant_backup  = lookup(var.server_storage_profile, "geo_redundant_backup", null)
    auto_grow             = lookup(var.server_storage_profile, "auto_grow", null)
  }

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_password
  version                      = var.postgresql_version
  ssl_enforcement              = var.postgresql_ssl_enforcement

  tags = merge(
    {
      "env"   = var.environment
      "stack" = var.stack
    },
    var.extra_tags,
  )
}

resource "azurerm_postgresql_database" "postgresql_db" {
  count               = length(var.databases_names)
  name                = element(var.databases_names, count.index)
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgresql_server.name
  charset             = var.databases_charset[element(var.databases_names, count.index)]
  collation           = var.databases_collation[element(var.databases_names, count.index)]
}

resource "azurerm_postgresql_configuration" "postgresql_config" {
  count               = length(var.postgresql_options)
  name                = var.postgresql_options[count.index].name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgresql_server.name
  value               = var.postgresql_options[count.index].value
}

resource "azurerm_postgresql_virtual_network_rule" "vnet_rules" {
  count               = length(var.postgresql_vnet_rules)
  name                = lookup(var.vnet_rules[count.index], "name", count.index)
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgresql_server.name
  subnet_id           = lookup(var.vnet_rules[count.index], "subnet_id")
}