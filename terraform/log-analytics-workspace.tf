resource "azurerm_log_analytics_workspace" "law" {
  name = format("la-%s-%s-%s", random_id.environment_id.hex, var.environment, var.locations[0])

  location            = var.locations[0]
  resource_group_name = azurerm_resource_group.rg[var.locations[0]].name

  sku = "PerGB2018"

  retention_in_days = 30
}