# terraform-azure-mcaf-vwan

The module can deploy a vwan with and without a secure hub.
It supports multiple firewall public IP configuration modes, each suited for different operational requirements.

## Firewall Public IP Modes

When `firewall_deploy = true`, you must choose how the firewall's public IPs are provisioned.
The mode is determined by the combination of `firewall_classic_ip_config`, `firewall_public_ip_count`,
`firewall_public_ip_prefix_length`, and `firewall_custom_ip_configurations`.

| Mode | `classic_ip_config` | `ip_count` | `prefix_length` | `custom_ip_configurations` | Description |
|------|:-------------------:|:----------:|:----------------:|:--------------------------:|-------------|
| **Classic** | `true` | required | - | - | Uses `azurerm_firewall` with the built-in IP count slider. Simplest setup. |
| **Count (AzAPI)** | `false` | set | - | optional | Creates individual `azurerm_public_ip` resources managed by the module. IPs persist across firewall rebuilds. |
| **Prefix (AzAPI)** | `false` | - | set | optional | Allocates an `azurerm_public_ip_prefix` and derives IPs from it. Guarantees a contiguous IP range. |
| **BYOIP (AzAPI)** | `false` | - | - | required | Uses only externally managed public IPs. Full control over IP lifecycle outside this module. |

**Notes:**
- Count + custom IPs and Prefix + custom IPs are valid combinations (IPs are concatenated).
- Classic mode cannot be combined with custom IPs or IP prefix.
- In BYOIP-only mode, the `vhub_firewall_public_ip_addresses` output returns `[]` because the module does not manage those IPs.

See [`examples/basic`](examples/basic) for count mode, [`examples/advanced`](examples/advanced) for prefix + custom IPs,
and [`examples/byoip`](examples/byoip) for BYOIP-only mode.

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vhub"></a> [vhub](#module\_vhub) | ./modules/vhub | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_hub_bgp_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_bgp_connection) | resource |
| [azurerm_virtual_wan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_wan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location/region where the VWAN will be created | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the VWAN will be created | `string` | n/a | yes |
| <a name="input_virtual_hubs"></a> [virtual\_hubs](#input\_virtual\_hubs) | This variable defines the configuration for virtual hubs, including firewall settings, routing, and security configurations.<br/><br/>- virtual\_hub\_name: The name of the virtual hub (string).<br/>- location: The Azure region where the virtual hub is deployed (string).<br/>- address\_prefix: The IP address prefix assigned to the virtual hub (string).<br/>- routing\_intent\_name: The name of the routing intent associated with the hub (string).<br/>- firewall\_deploy: Whether to deploy an Azure Firewall in the Virtual Hub (optional, defaults to true) (bool).<br/>- firewall\_classic\_ip\_config: Whether to use classic IP configuration for the firewall (optional, defaults to false) (bool).<br/>- firewall\_name: The name of the Azure Firewall deployed within the virtual hub (string).<br/>- firewall\_zones: Availability zones where the firewall is deployed (set of strings).<br/>- firewall\_policy\_name: The name of the firewall policy applied to the firewall (string).<br/>- firewall\_sku\_tier**: The SKU tier of the firewall (e.g., "Standard" or "Premium") (string).<br/>- firewall\_public\_ip\_count: The number of public IPs allocated to the firewall (optional, either this or firewall\_public\_ip\_prefix\_length should be specified) (number).<br/>- firewall\_public\_ip\_prefix\_length: The prefix length for the public IP prefix reservation (optional, either this or firewall\_public\_ip\_count should be specified) (number).<br/>- firewall\_public\_ip\_ddos\_protection\_mode: The DDoS protection mode for public IPs (optional, default is "VirtualNetworkInherited") (string).<br/>- firewall\_public\_ip\_ddos\_protection\_plan\_id: The ID of the DDoS protection plan for public IPs (optional, required if ddos\_protection\_mode is "Enabled") (string).<br/>- firewall\_threat\_intelligence\_mode: The mode of threat intelligence for the firewall (string).<br/>- firewall\_intrusion\_detection\_mode: The mode of intrusion detection (e.g., "Alert" or "Deny") (optional, defaults to "Alert") (string).<br/>- firewall\_dns\_proxy\_enabled: Indicates whether the DNS proxy is enabled for the firewall (bool).<br/>- firewall\_dns\_servers**: A list of DNS servers configured for the firewall (list of strings).<br/>- firewall\_intrusion\_detection\_private\_ranges: A list of private IP ranges for intrusion detection (optional, defaults to an empty list) (list of strings).<br/>- firewall\_custom\_ip\_configurations: A list of custom IP configurations to add to the firewall (optional, defaults to an empty list).<br/>  - name: The name of the IP configuration (string).<br/>  - public\_ip\_address\_id: The ID of the public IP address (string).<br/>- firewall\_intrusion\_detection\_signature\_overrides: A list of firewall intrusion detection signature overrides (optional, defaults to an empty list).<br/>  - id: The signature ID (string).<br/>  - state: The override state for the signature (string).<br/>- firewall\_intrusion\_detection\_traffic\_bypass: A list of rules for bypassing intrusion detection (optional, defaults to an empty list).<br/>  - name: The name of the bypass rule (string).<br/>  - protocol: The network protocol (e.g., "TCP", "UDP") (string).<br/>  - description: A description of the bypass rule (optional) (string).<br/>  - source\_addresses: A list of source IP addresses (optional, defaults to an empty list) (list of strings).<br/>  - source\_ip\_groups: A list of source IP groups (optional, defaults to an empty list) (list of strings).<br/>  - destination\_addresses: A list of destination IP addresses (optional, defaults to an empty list) (list of strings).<br/>  - destination\_ports: A list of destination ports (optional, defaults to an empty list) (list of strings).<br/>  - destination\_ip\_groups: A list of destination IP groups (optional, defaults to an empty list) (list of strings).<br/>- firewall\_intrusion\_detection\_tls\_certificate: A list of TLS certificates for intrusion detection (optional, defaults to an empty list).<br/>  - key\_vault\_secret\_id: The Key Vault secret ID storing the certificate (string).<br/>  - name: The name of the TLS certificate (string). | <pre>map(object({<br/>    virtual_hub_name                            = string<br/>    address_prefix                              = string<br/>    location                                    = string<br/>    enable_routing_intent                       = optional(bool, true)<br/>    routing_intent_name                         = optional(string)<br/>    firewall_deploy                             = optional(bool, true)<br/>    firewall_classic_ip_config                  = optional(bool, false)<br/>    firewall_name                               = optional(string)<br/>    firewall_zones                              = optional(set(string), ["1", "2", "3"])<br/>    firewall_policy_name                        = optional(string)<br/>    firewall_sku_tier                           = optional(string)<br/>    firewall_public_ip_count                    = optional(number)<br/>    firewall_public_ip_prefix_length            = optional(number, 0)<br/>    firewall_public_ip_ddos_protection_mode     = optional(string, "VirtualNetworkInherited")<br/>    firewall_public_ip_ddos_protection_plan_id  = optional(string)<br/>    firewall_threat_intelligence_mode           = optional(string, "Deny")<br/>    firewall_intrusion_detection_mode           = optional(string, "Deny")<br/>    firewall_dns_proxy_enabled                  = optional(bool, true)<br/>    firewall_dns_servers                        = optional(list(string))<br/>    firewall_intrusion_detection_private_ranges = optional(list(string), [])<br/>    firewall_custom_ip_configurations = optional(list(object({<br/>      name                 = string<br/>      public_ip_address_id = string<br/>    })), [])<br/>    firewall_intrusion_detection_signature_overrides = optional(list(object({<br/>      id    = string<br/>      state = string<br/>    })), [])<br/>    firewall_intrusion_detection_traffic_bypass = optional(list(object({<br/>      name                  = string<br/>      protocol              = string<br/>      description           = optional(string)<br/>      source_addresses      = optional(list(string), [])<br/>      source_ip_groups      = optional(list(string), [])<br/>      destination_addresses = optional(list(string), [])<br/>      destination_ports     = optional(list(string), [])<br/>      destination_ip_groups = optional(list(string), [])<br/>    })), [])<br/>    firewall_intrusion_detection_tls_certificate = optional(object({<br/>      key_vault_secret_id = string<br/>      name                = string<br/>    }), null)<br/>    firewall_insights_enabled                            = optional(bool, false)<br/>    firewall_insights_default_log_analytics_workspace_id = optional(string)<br/>    firewall_insights_retention_in_days                  = optional(number)<br/>    firewall_insights_log_analytics_workspaces = optional(list(object({<br/>      id                = string<br/>      firewall_location = string<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_virtual_wan"></a> [virtual\_wan](#input\_virtual\_wan) | This variable defines the configuration for the virtual WAN.<br/>- name: The name of the virtual WAN (string).<br/>- type: The type of the virtual WAN (string).<br/>- disable\_vpn\_encryption: Whether VPN encryption is disabled (bool).<br/>- allow\_branch\_to\_branch\_traffic: Whether branch-to-branch traffic is allowed (bool).<br/>- office365\_local\_breakout\_category: The category for Office 365 local breakout (string). | <pre>object({<br/>    name                              = string<br/>    type                              = optional(string, "Standard")<br/>    disable_vpn_encryption            = optional(bool, false)<br/>    allow_branch_to_branch_traffic    = optional(bool, true)<br/>    office365_local_breakout_category = optional(string, "None")<br/>  })</pre> | n/a | yes |
| <a name="input_create_new_resource_group"></a> [create\_new\_resource\_group](#input\_create\_new\_resource\_group) | If true, a new Resourcegroup will be created | `bool` | `false` | no |
| <a name="input_hub_bgp_peers"></a> [hub\_bgp\_peers](#input\_hub\_bgp\_peers) | This variable defines the configuration for BGP peers.<br/>- virtual\_hub\_id: The ID of the virtual hub (string).<br/>- name: The name of the BGP peer (string).<br/>- peer\_asn: The ASN of the BGP peer (number).<br/>- peer\_ip: The IP address of the BGP peer (string).<br/>- vnet\_connection\_id: The ID of the VNET Hub connection (string). | <pre>map(object({<br/>    virtual_hub_id     = string<br/>    name               = string<br/>    peer_asn           = number<br/>    peer_ip            = string<br/>    vnet_connection_id = string<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the Resource Group created by the module |
| <a name="output_vhub_address_prefixes"></a> [vhub\_address\_prefixes](#output\_vhub\_address\_prefixes) | Map of Address Prefixes used for each Virtual Hub |
| <a name="output_vhub_default_route_table_ids"></a> [vhub\_default\_route\_table\_ids](#output\_vhub\_default\_route\_table\_ids) | Map of IDs of the default Route Tables in each Virtual Hub |
| <a name="output_vhub_firewall_ids"></a> [vhub\_firewall\_ids](#output\_vhub\_firewall\_ids) | Map of IDs of the Firewalls created in each Virtual Hub |
| <a name="output_vhub_firewall_policy_ids"></a> [vhub\_firewall\_policy\_ids](#output\_vhub\_firewall\_policy\_ids) | Map of IDs of the Firewall Policies created in each Virtual Hub |
| <a name="output_vhub_firewall_public_ip_addresses"></a> [vhub\_firewall\_public\_ip\_addresses](#output\_vhub\_firewall\_public\_ip\_addresses) | Map of public IP addresses of the Firewalls created in each Virtual Hub |
| <a name="output_vhub_ids"></a> [vhub\_ids](#output\_vhub\_ids) | Map of IDs of the Virtual Hubs created by the module |
| <a name="output_vhub_names"></a> [vhub\_names](#output\_vhub\_names) | Map of names of the Virtual Hubs created by the module |
| <a name="output_vhub_virtual_router_asns"></a> [vhub\_virtual\_router\_asns](#output\_vhub\_virtual\_router\_asns) | Map of Autonomous System Numbers of the Virtual Hub BGP routers |
| <a name="output_vhub_virtual_router_ips"></a> [vhub\_virtual\_router\_ips](#output\_vhub\_virtual\_router\_ips) | Map of IP addresses of the Virtual Hub BGP routers |
| <a name="output_virtual_wan"></a> [virtual\_wan](#output\_virtual\_wan) | output the resource of the vwan |
| <a name="output_virtual_wan_id"></a> [virtual\_wan\_id](#output\_virtual\_wan\_id) | ID of the Virtual wan created by the module |
<!-- END_TF_DOCS -->
