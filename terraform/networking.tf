// Create a virtual network that will host the Function App
resource "azurerm_virtual_network" "apps" {
  for_each = toset(var.locations)

  name          = format("vnet-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)
  address_space = ["10.0.0.0/16"]

  resource_group_name = azurerm_resource_group.rg[each.value].name
  location            = azurerm_resource_group.rg[each.value].location
}

// Create a subnet that will host the private endpoints for the Function App and it's storage account
resource "azurerm_subnet" "endpoints" {
  for_each = toset(var.locations)

  name = format("snet-integration-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name  = azurerm_resource_group.rg[each.value].name
  virtual_network_name = azurerm_virtual_network.apps[each.value].name

  address_prefixes = ["10.0.1.0/24"]
}

// Create a subnet that will host the Function App's App Service Plan for the VNet integration
resource "azurerm_subnet" "app_01" {
  for_each = toset(var.locations)

  name = format("snet-app-01-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name  = azurerm_resource_group.rg[each.value].name
  virtual_network_name = azurerm_virtual_network.apps[each.value].name

  address_prefixes = ["10.0.2.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action", "Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "app_02" {
  for_each = toset(var.locations)

  name = format("snet-app-02-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name  = azurerm_resource_group.rg[each.value].name
  virtual_network_name = azurerm_virtual_network.apps[each.value].name

  address_prefixes = ["10.0.3.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action", "Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "app_03" {
  for_each = toset(var.locations)

  name = format("snet-app-01-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name  = azurerm_resource_group.rg[each.value].name
  virtual_network_name = azurerm_virtual_network.apps[each.value].name

  address_prefixes = ["10.0.4.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action", "Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "app_04" {
  for_each = toset(var.locations)

  name = format("snet-app-02-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name  = azurerm_resource_group.rg[each.value].name
  virtual_network_name = azurerm_virtual_network.apps[each.value].name

  address_prefixes = ["10.0.5.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action", "Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "app_05" {
  for_each = toset(var.locations)

  name = format("snet-app-05-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name  = azurerm_resource_group.rg[each.value].name
  virtual_network_name = azurerm_virtual_network.apps[each.value].name

  address_prefixes = ["10.0.6.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action", "Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

// Create the private DNS zones for the private link resources that the Function App and Storage will use
resource "azurerm_private_dns_zone" "azurewebsites" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg[var.primary_location].name
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg[var.primary_location].name
}

resource "azurerm_private_dns_zone" "table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.rg[var.primary_location].name
}

resource "azurerm_private_dns_zone" "queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.rg[var.primary_location].name
}

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg[var.primary_location].name
}

// Link the private DNS zones to the virtual network to enable private link DNS zone resolution
resource "azurerm_private_dns_zone_virtual_network_link" "azurewebsites" {
  for_each = toset(var.locations)

  name                  = format("link-azurewebsites-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)
  resource_group_name   = azurerm_resource_group.rg[var.primary_location].name
  private_dns_zone_name = azurerm_private_dns_zone.azurewebsites.name
  virtual_network_id    = azurerm_virtual_network.apps[each.value].id
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  for_each = toset(var.locations)

  name                  = format("link-blob-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)
  resource_group_name   = azurerm_resource_group.rg[var.primary_location].name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.apps[each.value].id
}

resource "azurerm_private_dns_zone_virtual_network_link" "table" {
  for_each = toset(var.locations)

  name                  = format("link-table-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)
  resource_group_name   = azurerm_resource_group.rg[var.primary_location].name
  private_dns_zone_name = azurerm_private_dns_zone.table.name
  virtual_network_id    = azurerm_virtual_network.apps[each.value].id
}

resource "azurerm_private_dns_zone_virtual_network_link" "queue" {
  for_each = toset(var.locations)

  name                  = format("link-queue-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)
  resource_group_name   = azurerm_resource_group.rg[var.primary_location].name
  private_dns_zone_name = azurerm_private_dns_zone.queue.name
  virtual_network_id    = azurerm_virtual_network.apps[each.value].id
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  for_each = toset(var.locations)

  name                  = format("link-file-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)
  resource_group_name   = azurerm_resource_group.rg[var.primary_location].name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = azurerm_virtual_network.apps[each.value].id
}
