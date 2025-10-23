## Snowflake on Azure - Private Link Terraform Template

This template scaffolds the Azure resources to connect to Snowflake via Azure Private Link, including:

- Resource Group
- VNet and Private Endpoint subnet
- Private Endpoint (manual connection) targeting the Snowflake Private Link service alias
- Private DNS zone(s) and optional A records pointing to the Private Endpoint IP

Important: The Private Endpoint uses manual approval. A Snowflake admin must approve the connection in Snowflake after you create it.

### Prerequisites

- Terraform >= 1.5
- Azure subscription with sufficient permissions
- Snowflake account with PrivateLink for Azure enabled and the provided service alias
- Logged into Azure (e.g., `az login`)

### Files

- `providers.tf`: Terraform and provider configuration
- `variables.tf`: Input variables
- `main.tf`: Core resources (RG, VNet, Subnet, Private Endpoint, DNS)
- `outputs.tf`: Useful outputs
- `terraform.tfvars.example`: Example variable values

### Quick Start

1. Copy the example tfvars and edit values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Set `snowflake_privatelink_service_alias` using the alias provided by Snowflake.

3. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

4. Approve the Private Endpoint in Snowflake (or wait for Snowflake to approve), then optionally add DNS A records for your Snowflake account hostname(s) in `dns_a_records`.

### Variables

Key variables:

- `project_name`: Short name to tag resource names
- `resource_group_name`: Name of the RG
- `location`: Azure region
- `vnet_address_space`: VNet address space
- `subnet_address_prefixes`: Subnet CIDR(s) for the Private Endpoint
- `snowflake_privatelink_service_alias`: The Snowflake Private Link service alias (region/account specific)
- `private_dns_zone_names`: DNS zones to create (defaults to `privatelink.azure.snowflakecomputing.com`)
- `dns_a_records`: Optional A records to create within the private DNS zone(s)

### Notes

- DNS configuration for Snowflake may vary by region and account features. Confirm the correct zone names and hostnames for your account.
- The template sets NIC IP as the A record target via `local.private_ip`.
- For multi-zone/different endpoints (e.g., OCSP or account-specific endpoints), add additional entries to `private_dns_zone_names` and `dns_a_records` as required by Snowflake.


