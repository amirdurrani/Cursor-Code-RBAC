output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.snowflake.id
}

output "private_endpoint_ip" {
  value = local.private_ip
}

output "private_dns_zone_names" {
  value = [for z in azurerm_private_dns_zone.zones : z.name]
}


