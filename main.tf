resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project_name}"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "pe" {
  name                 = var.private_endpoint_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes

  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_private_endpoint" "snowflake" {
  name                = "pe-snowflake-${var.project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pe.id

  private_service_connection {
    name                               = "snowflake-privatelink"
    is_manual_connection               = true
    private_connection_resource_alias  = var.snowflake_privatelink_service_alias
    request_message                    = "Requesting connection to Snowflake PrivateLink from ${var.project_name}"
  }
}

data "azurerm_network_interface" "pe_nic" {
  name                = azurerm_private_endpoint.snowflake.network_interface[0].name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_private_endpoint.snowflake]
}

locals {
  private_ip = data.azurerm_network_interface.pe_nic.ip_configuration[0].private_ip_address
}

resource "azurerm_private_dns_zone" "zones" {
  for_each            = toset(var.private_dns_zone_names)
  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each              = azurerm_private_dns_zone.zones
  name                  = "${replace(each.value.name, ".", "-")}-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = each.value.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_a_record" "records" {
  for_each            = { for r in var.dns_a_records : "${r.zone_name}/${r.name}" => r }
  name                = each.value.name
  zone_name           = each.value.zone_name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [local.private_ip]
  depends_on          = [azurerm_private_dns_zone.zones]
}


