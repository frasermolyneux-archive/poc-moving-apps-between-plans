data "azurerm_dns_zone" "dns" {
  name                = "mngenv102652.com"
  resource_group_name = "rg-dns"
}
