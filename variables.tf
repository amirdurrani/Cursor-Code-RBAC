variable "project_name" {
  description = "A short name used to name resources."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Name of the resource group to create/use."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the VNet."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the Private Endpoint subnet."
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "private_endpoint_subnet_name" {
  description = "Name of the subnet to host the Private Endpoint."
  type        = string
  default     = "snet-privatelink"
}

variable "snowflake_privatelink_service_alias" {
  description = "Snowflake Azure Private Link service alias to connect to (from Snowflake)."
  type        = string
}

variable "private_dns_zone_names" {
  description = "Private DNS zone names to create/link for Snowflake PrivateLink."
  type        = list(string)
  default     = [
    "privatelink.azure.snowflakecomputing.com",
  ]
}

variable "dns_a_records" {
  description = "A records to create inside the private DNS zones (label-only name; zone_name must match one of private_dns_zone_names)."
  type = list(object({
    zone_name = string
    name      = string
  }))
  default = []
}


variable "rbac_assignments" {
  description = "RBAC role assignments to apply. Each item targets a scope type and principal/object, with an optional condition."
  type = list(object({
    scope_type   = string            # one of: "resource_group", "virtual_network", "subnet", "private_endpoint", "private_dns_zone"
    scope_name   = optional(string)  # required for private_dns_zone (zone name) and used to disambiguate
    role_name    = string            # e.g., 'Contributor', 'Reader', 'Private DNS Zone Contributor'
    principal_id = string            # Azure AD objectId of user/group/app
    condition    = optional(string)
    condition_version = optional(string)
  }))
  default = []
}


