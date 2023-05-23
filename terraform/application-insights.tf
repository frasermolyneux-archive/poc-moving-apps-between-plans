resource "azurerm_application_insights" "ai" {
  for_each = toset(var.locations)

  name = format("ai-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name = azurerm_resource_group.rg[each.value].name
  location            = azurerm_resource_group.rg[each.value].location

  workspace_id = azurerm_log_analytics_workspace.law.id

  application_type = "web"
}