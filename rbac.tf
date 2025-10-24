locals {
  rbac_role_definitions = {
    # Common built-ins; users can also pass a custom role definition id via role_name = <GUID>
    "Owner"                               = data.azurerm_role_definition.owner.id
    "Contributor"                         = data.azurerm_role_definition.contributor.id
    "Reader"                              = data.azurerm_role_definition.reader.id
    "Network Contributor"                 = data.azurerm_role_definition.network_contributor.id
    "Private DNS Zone Contributor"        = data.azurerm_role_definition.private_dns_zone_contributor.id
  }
}

data "azurerm_subscription" "current" {}

data "azurerm_role_definition" "owner" { name = "Owner" }
data "azurerm_role_definition" "contributor" { name = "Contributor" }
data "azurerm_role_definition" "reader" { name = "Reader" }
data "azurerm_role_definition" "network_contributor" { name = "Network Contributor" }
data "azurerm_role_definition" "private_dns_zone_contributor" { name = "Private DNS Zone Contributor" }

# Resolve scope per assignment
locals {
  rbac_assignments_expanded = [for a in var.rbac_assignments : merge(a, {
    role_definition_id = try(
      can(regex("^[0-9a-fA-F-]{36}$", a.role_name)) ? a.role_name : local.rbac_role_definitions[a.role_name],
      a.role_name
    )
    scope = (
      a.scope_type == "resource_group"   ? azurerm_resource_group.rg.id :
      a.scope_type == "virtual_network"  ? azurerm_virtual_network.vnet.id :
      a.scope_type == "subnet"           ? azurerm_subnet.pe.id :
      a.scope_type == "private_endpoint" ? azurerm_private_endpoint.snowflake.id :
      a.scope_type == "private_dns_zone" ? azurerm_private_dns_zone.zones[a.scope_name].id :
      azurerm_resource_group.rg.id
    )
  })]
}

resource "azurerm_role_assignment" "rbac" {
  for_each             = { for i, a in local.rbac_assignments_expanded : i => a }
  scope                = each.value.scope
  role_definition_id   = each.value.role_definition_id
  principal_id         = each.value.principal_id
  condition            = try(each.value.condition, null)
  condition_version    = try(each.value.condition_version, null)
  skip_service_principal_aad_check = true
}


