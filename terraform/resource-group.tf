resource "azurerm_resource_group" "rg" {
  for_each = toset(var.locations)

  name     = format("rg-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)
  location = each.value

  tags = var.tags
}