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


