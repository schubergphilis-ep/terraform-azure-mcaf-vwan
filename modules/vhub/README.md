<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.firewall](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_firewall.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_firewall_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip_prefix.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) | resource |
| [azurerm_virtual_hub.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub) | resource |
| [azurerm_virtual_hub_routing_intent.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_routing_intent) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_prefix"></a> [address\_prefix](#input\_address\_prefix) | The IP address prefix assigned to the virtual hub (e.g., '10.0.0.0/16'). | `string` | n/a | yes |
| <a name="input_enable_routing_intent"></a> [enable\_routing\_intent](#input\_enable\_routing\_intent) | Indicates wheter or not to configure routing intent. | `bool` | n/a | yes |
| <a name="input_firewall_dns_proxy_enabled"></a> [firewall\_dns\_proxy\_enabled](#input\_firewall\_dns\_proxy\_enabled) | Indicates whether the DNS proxy is enabled for the firewall. | `bool` | n/a | yes |
| <a name="input_firewall_dns_servers"></a> [firewall\_dns\_servers](#input\_firewall\_dns\_servers) | A list of DNS servers configured for the firewall. | `list(string)` | n/a | yes |
| <a name="input_firewall_name"></a> [firewall\_name](#input\_firewall\_name) | The name of the Azure Firewall deployed within the virtual hub. | `string` | n/a | yes |
| <a name="input_firewall_policy_name"></a> [firewall\_policy\_name](#input\_firewall\_policy\_name) | The name of the firewall policy applied to the Azure Firewall. | `string` | n/a | yes |
| <a name="input_firewall_sku_tier"></a> [firewall\_sku\_tier](#input\_firewall\_sku\_tier) | The SKU tier of the firewall (e.g. 'Basic', 'Standard' or 'Premium'). | `string` | n/a | yes |
| <a name="input_firewall_threat_intelligence_mode"></a> [firewall\_threat\_intelligence\_mode](#input\_firewall\_threat\_intelligence\_mode) | The mode of threat intelligence for the firewall (e.g., 'Alert', 'Deny', or 'Off'). | `string` | n/a | yes |
| <a name="input_firewall_zones"></a> [firewall\_zones](#input\_firewall\_zones) | Availability zones where the firewall is deployed (e.g., ['1', '2', '3']). | `set(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the virtual hub is deployed. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the VWAN will be created | `string` | n/a | yes |
| <a name="input_routing_intent_name"></a> [routing\_intent\_name](#input\_routing\_intent\_name) | The name of the routing intent associated with the virtual hub. | `string` | n/a | yes |
| <a name="input_virtual_hub_name"></a> [virtual\_hub\_name](#input\_virtual\_hub\_name) | The name of the virtual hub. | `string` | n/a | yes |
| <a name="input_virtual_wan_id"></a> [virtual\_wan\_id](#input\_virtual\_wan\_id) | The ID of the virtual WAN. | `string` | n/a | yes |
| <a name="input_firewall_classic_ip_config"></a> [firewall\_classic\_ip\_config](#input\_firewall\_classic\_ip\_config) | Controls whether to use classic IP configuration for the firewall. | `bool` | `false` | no |
| <a name="input_firewall_custom_ip_configurations"></a> [firewall\_custom\_ip\_configurations](#input\_firewall\_custom\_ip\_configurations) | List of custom IP configurations to add to the firewall. Each object must contain 'name' and 'public\_ip\_address\_id'. | <pre>list(object({<br/>    name                 = string<br/>    public_ip_address_id = string<br/>  }))</pre> | `[]` | no |
| <a name="input_firewall_deploy"></a> [firewall\_deploy](#input\_firewall\_deploy) | Controls whether to deploy an Azure Firewall in the Virtual Hub | `bool` | `true` | no |
| <a name="input_firewall_insights_default_log_analytics_workspace_id"></a> [firewall\_insights\_default\_log\_analytics\_workspace\_id](#input\_firewall\_insights\_default\_log\_analytics\_workspace\_id) | The ID of the default Log Analytics Workspace that the Firewalls associated with this Firewall Policy will send their logs to, when there is no location matches in the log\_analytics\_workspace. | `string` | `null` | no |
| <a name="input_firewall_insights_enabled"></a> [firewall\_insights\_enabled](#input\_firewall\_insights\_enabled) | Whether the insights functionality is enabled for this Firewall Policy. | `bool` | `false` | no |
| <a name="input_firewall_insights_log_analytics_workspaces"></a> [firewall\_insights\_log\_analytics\_workspaces](#input\_firewall\_insights\_log\_analytics\_workspaces) | A list of log\_analytics\_workspace blocks. Each object must contain 'id' (the Log Analytics Workspace ID) and 'firewall\_location' (the location of the Firewalls). | <pre>list(object({<br/>    id                = string<br/>    firewall_location = string<br/>  }))</pre> | `[]` | no |
| <a name="input_firewall_insights_retention_in_days"></a> [firewall\_insights\_retention\_in\_days](#input\_firewall\_insights\_retention\_in\_days) | The log retention period in days for firewall insights. | `number` | `null` | no |
| <a name="input_firewall_intrusion_detection_mode"></a> [firewall\_intrusion\_detection\_mode](#input\_firewall\_intrusion\_detection\_mode) | The mode of intrusion detection (e.g., 'Alert', 'Deny' or 'Off'). | `string` | `"Alert"` | no |
| <a name="input_firewall_intrusion_detection_private_ranges"></a> [firewall\_intrusion\_detection\_private\_ranges](#input\_firewall\_intrusion\_detection\_private\_ranges) | A list of private IP ranges for intrusion detection. | `list(string)` | `[]` | no |
| <a name="input_firewall_intrusion_detection_signature_overrides"></a> [firewall\_intrusion\_detection\_signature\_overrides](#input\_firewall\_intrusion\_detection\_signature\_overrides) | A list of firewall intrusion detection signature overrides. | <pre>list(object({<br/>    id    = string<br/>    state = string<br/>  }))</pre> | `[]` | no |
| <a name="input_firewall_intrusion_detection_tls_certificate"></a> [firewall\_intrusion\_detection\_tls\_certificate](#input\_firewall\_intrusion\_detection\_tls\_certificate) | TLS certificate used for intrusion detection (stored in Key Vault). | <pre>object({<br/>    key_vault_secret_id = string<br/>    name                = string<br/>  })</pre> | `null` | no |
| <a name="input_firewall_intrusion_detection_traffic_bypass"></a> [firewall\_intrusion\_detection\_traffic\_bypass](#input\_firewall\_intrusion\_detection\_traffic\_bypass) | A list of rules for bypassing intrusion detection. | <pre>list(object({<br/>    name                  = string<br/>    protocol              = string<br/>    description           = optional(string)<br/>    source_addresses      = optional(list(string), [])<br/>    source_ip_groups      = optional(list(string), [])<br/>    destination_addresses = optional(list(string), [])<br/>    destination_ports     = optional(list(string), [])<br/>    destination_ip_groups = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_firewall_public_ip_count"></a> [firewall\_public\_ip\_count](#input\_firewall\_public\_ip\_count) | The number of public IPs allocated to the firewall. Required if firewall\_public\_ip\_prefix\_id is not set. | `number` | `null` | no |
| <a name="input_firewall_public_ip_ddos_protection_mode"></a> [firewall\_public\_ip\_ddos\_protection\_mode](#input\_firewall\_public\_ip\_ddos\_protection\_mode) | The DDoS protection mode for the public IP. Possible values are Disabled, Enabled, and VirtualNetworkInherited. | `string` | `"VirtualNetworkInherited"` | no |
| <a name="input_firewall_public_ip_ddos_protection_plan_id"></a> [firewall\_public\_ip\_ddos\_protection\_plan\_id](#input\_firewall\_public\_ip\_ddos\_protection\_plan\_id) | The ID of the DDoS protection plan to be attached to the public IP. Required if ddos\_protection\_mode is Enabled. | `string` | `null` | no |
| <a name="input_firewall_public_ip_prefix_length"></a> [firewall\_public\_ip\_prefix\_length](#input\_firewall\_public\_ip\_prefix\_length) | The public ip prefix length that will be requested for the firewall. Required if firewall\_public\_ip\_count is not set. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_prefix"></a> [address\_prefix](#output\_address\_prefix) | The Address Prefix used for this Virtual Hub. |
| <a name="output_default_route_table_id"></a> [default\_route\_table\_id](#output\_default\_route\_table\_id) | The ID of the default Route Table in the Virtual Hub. |
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | The ID of the Firewall within the Virtual Hub. |
| <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id) | The ID of the Firewall Policy within the Virtual Hub. |
| <a name="output_firewall_public_ip_addresses"></a> [firewall\_public\_ip\_addresses](#output\_firewall\_public\_ip\_addresses) | The public IP addresses of the Firewall. |
| <a name="output_routing_intent_id"></a> [routing\_intent\_id](#output\_routing\_intent\_id) | The ID of the routing intent for this Virtual Hub. |
| <a name="output_vhub_id"></a> [vhub\_id](#output\_vhub\_id) | The ID of the Virtual WAN within which the Virtual Hub exists. |
| <a name="output_vhub_name"></a> [vhub\_name](#output\_vhub\_name) | The name of the Virtual Hub. |
| <a name="output_virtual_router_asn"></a> [virtual\_router\_asn](#output\_virtual\_router\_asn) | The Autonomous System Number of the Virtual Hub BGP router. |
| <a name="output_virtual_router_ips"></a> [virtual\_router\_ips](#output\_virtual\_router\_ips) | The IP addresses of the Virtual Hub BGP router. |
<!-- END_TF_DOCS -->
