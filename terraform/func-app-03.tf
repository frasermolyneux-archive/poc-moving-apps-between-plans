resource "azurerm_storage_account" "fa_03" {
  for_each = toset(var.locations)

  name = format("sa%s03", lower(random_string.location[each.value].result))

  resource_group_name = azurerm_resource_group.fa_01[each.value].name
  location            = azurerm_resource_group.fa_01[each.value].location

  // Consider your disaster recovery requirements when setting tier and replication type
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"

  public_network_access_enabled = false
}

// Create the private endpoints for the storage account. The function needs different endpoints depending on what features are being used.
resource "azurerm_private_endpoint" "fa_03_blob" {
  for_each = toset(var.locations)

  name = format("pe-%s-blob-03", azurerm_storage_account.fa_03[each.value].name)

  resource_group_name = azurerm_resource_group.fa_01[each.value].name
  location            = azurerm_resource_group.fa_01[each.value].location

  subnet_id = azurerm_subnet.endpoints[each.value].id

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.blob.id,
    ]
  }

  private_service_connection {
    name                           = format("pe-%s-blob-03", azurerm_storage_account.fa_03[each.value].name)
    private_connection_resource_id = azurerm_storage_account.fa_03[each.value].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "fa_03_table" {
  for_each = toset(var.locations)

  name = format("pe-%s-table-03", azurerm_storage_account.fa_03[each.value].name)

  resource_group_name = azurerm_resource_group.fa_01[each.value].name
  location            = azurerm_resource_group.fa_01[each.value].location

  subnet_id = azurerm_subnet.endpoints[each.value].id

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.table.id,
    ]
  }

  private_service_connection {
    name                           = format("pe-%s-table-03", azurerm_storage_account.fa_03[each.value].name)
    private_connection_resource_id = azurerm_storage_account.fa_03[each.value].id
    subresource_names              = ["table"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "fa_03_queue" {
  for_each = toset(var.locations)

  name = format("pe-%s-queue-03", azurerm_storage_account.fa_03[each.value].name)

  resource_group_name = azurerm_resource_group.fa_01[each.value].name
  location            = azurerm_resource_group.fa_01[each.value].location

  subnet_id = azurerm_subnet.endpoints[each.value].id

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.queue.id,
    ]
  }

  private_service_connection {
    name                           = format("pe-%s-queue-03", azurerm_storage_account.fa_03[each.value].name)
    private_connection_resource_id = azurerm_storage_account.fa_03[each.value].id
    subresource_names              = ["queue"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "fa_03_file" {
  for_each = toset(var.locations)

  name = format("pe-%s-file-03", azurerm_storage_account.fa_03[each.value].name)

  resource_group_name = azurerm_resource_group.fa_01[each.value].name
  location            = azurerm_resource_group.fa_01[each.value].location

  subnet_id = azurerm_subnet.endpoints[each.value].id

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.file.id,
    ]
  }

  private_service_connection {
    name                           = format("pe-%s-file-03", azurerm_storage_account.fa_03[each.value].name)
    private_connection_resource_id = azurerm_storage_account.fa_03[each.value].id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}

//Create the Linux function app; this sets the application stack as dotnet for example only
resource "azurerm_linux_function_app" "fa_03" {
  for_each = toset(var.locations)

  name = format("fa-%s-%s-%s-03", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name = azurerm_resource_group.fa_01[each.value].name
  location            = azurerm_resource_group.fa_01[each.value].location

  // Consider replacing this with managed identity access over access keys
  storage_account_name       = azurerm_storage_account.fa_03[each.value].name
  storage_account_access_key = azurerm_storage_account.fa_03[each.value].primary_access_key
  service_plan_id            = azurerm_service_plan.fa_01[each.value].id

  // Set the virtual network integration that will be used for *outbound* traffic from the function app
  virtual_network_subnet_id = azurerm_subnet.fa_01[each.value].id

  // Consider setting other site_config settings as appropriate for your function app in production such as app insights etc.
  site_config {
    // Set VNet route_all_enabled to force all egress traffic to go through the VNet
    vnet_route_all_enabled = true

    // Application stack is set as dotnet for example only
    application_stack {
      dotnet_version = "7.0"
    }
  }

  content_share_force_disabled = true // This is required to prevent the `WEBSITE_CONTENTSHARE` and `WEBSITE_CONTENTAZUREFILECONNECTIONSTRING` being added as these app settings aren't required for Linux apps on Elastic Premium.

  app_settings = {
    // Add any app settings as required for your function app in production here
    https_only = true
  }

  // For the first time run scenario, we need to ensure that the private endpoints are created before the function app
  depends_on = [
    azurerm_private_endpoint.fa_03_blob,
    azurerm_private_endpoint.fa_03_table,
    azurerm_private_endpoint.fa_03_queue,
    azurerm_private_endpoint.fa_03_file
  ]
}

resource "azurerm_private_endpoint" "fa_03_fa_sites_pe" {
  for_each = toset(var.locations)

  name = format("pe-%s-sites-03", azurerm_storage_account.fa_03[each.value].name)

  resource_group_name = azurerm_resource_group.fa_01[each.value].name
  location            = azurerm_resource_group.fa_01[each.value].location

  subnet_id = azurerm_subnet.endpoints[each.value].id

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.azurewebsites.id,
    ]
  }

  private_service_connection {
    name                           = format("pe-%s-sites-03", azurerm_linux_function_app.fa_03[each.value].name)
    private_connection_resource_id = azurerm_linux_function_app.fa_03[each.value].id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}
