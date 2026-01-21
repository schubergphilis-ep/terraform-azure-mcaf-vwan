variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the VWAN will be created"
}

variable "create_new_resource_group" {
  type        = bool
  description = "If true, a new Resourcegroup will be created"
  default     = false
}

variable "location" {
  type        = string
  description = "The location/region where the VWAN will be created"
}

variable "virtual_wan" {
  type = object({
    name                              = string
    type                              = optional(string, "Standard")
    disable_vpn_encryption            = optional(bool, false)
    allow_branch_to_branch_traffic    = optional(bool, true)
    office365_local_breakout_category = optional(string, "None")
  })
  description = <<DESCRIPTION
This variable defines the configuration for the virtual WAN.
- name: The name of the virtual WAN (string).
- type: The type of the virtual WAN (string).
- disable_vpn_encryption: Whether VPN encryption is disabled (bool).
- allow_branch_to_branch_traffic: Whether branch-to-branch traffic is allowed (bool).
- office365_local_breakout_category: The category for Office 365 local breakout (string).
DESCRIPTION
}

variable "virtual_hubs" {
  type = map(object({
    virtual_hub_name                            = string
    address_prefix                              = string
    location                                    = string
    enable_routing_intent                       = optional(bool, true)
    routing_intent_name                         = optional(string)
    firewall_deploy                             = optional(bool, true)
    firewall_classic_ip_config                  = optional(bool, false)
    firewall_name                               = optional(string)
    firewall_zones                              = optional(set(string), ["1", "2", "3"])
    firewall_policy_name                        = optional(string)
    firewall_sku_tier                           = optional(string)
    firewall_public_ip_count                    = optional(number)
    firewall_public_ip_prefix_length            = optional(number, 0)
    firewall_public_ip_ddos_protection_mode     = optional(string, "VirtualNetworkInherited")
    firewall_public_ip_ddos_protection_plan_id  = optional(string)
    firewall_threat_intelligence_mode           = optional(string, "Deny")
    firewall_intrusion_detection_mode           = optional(string, "Deny")
    firewall_dns_proxy_enabled                  = optional(bool, true)
    firewall_dns_servers                        = optional(list(string))
    firewall_intrusion_detection_private_ranges = optional(list(string), [])
    firewall_custom_ip_configurations = optional(list(object({
      name                 = string
      public_ip_address_id = string
    })), [])
    firewall_intrusion_detection_signature_overrides = optional(list(object({
      id    = string
      state = string
    })), [])
    firewall_intrusion_detection_traffic_bypass = optional(list(object({
      name                  = string
      protocol              = string
      description           = optional(string)
      source_addresses      = optional(list(string), [])
      source_ip_groups      = optional(list(string), [])
      destination_addresses = optional(list(string), [])
      destination_ports     = optional(list(string), [])
      destination_ip_groups = optional(list(string), [])
    })), [])
    firewall_intrusion_detection_tls_certificate = optional(object({
      key_vault_secret_id = string
      name                = string
    }), null)
    firewall_insights_enabled                            = optional(bool, false)
    firewall_insights_default_log_analytics_workspace_id = optional(string)
    firewall_insights_retention_in_days                  = optional(number)
    firewall_insights_log_analytics_workspaces = optional(list(object({
      id                = string
      firewall_location = string
    })), [])
  }))

  description = <<DESCRIPTION
This variable defines the configuration for virtual hubs, including firewall settings, routing, and security configurations.

- virtual_hub_name: The name of the virtual hub (string).
- location: The Azure region where the virtual hub is deployed (string).
- address_prefix: The IP address prefix assigned to the virtual hub (string).
- routing_intent_name: The name of the routing intent associated with the hub (string).
- firewall_deploy: Whether to deploy an Azure Firewall in the Virtual Hub (optional, defaults to true) (bool).
- firewall_classic_ip_config: Whether to use classic IP configuration for the firewall (optional, defaults to false) (bool).
- firewall_name: The name of the Azure Firewall deployed within the virtual hub (string).
- firewall_zones: Availability zones where the firewall is deployed (set of strings).
- firewall_policy_name: The name of the firewall policy applied to the firewall (string).
- firewall_sku_tier**: The SKU tier of the firewall (e.g., "Standard" or "Premium") (string).
- firewall_public_ip_count: The number of public IPs allocated to the firewall (optional, either this or firewall_public_ip_prefix_length should be specified) (number).
- firewall_public_ip_prefix_length: The prefix length for the public IP prefix reservation (optional, either this or firewall_public_ip_count should be specified) (number).
- firewall_public_ip_ddos_protection_mode: The DDoS protection mode for public IPs (optional, default is "VirtualNetworkInherited") (string).
- firewall_public_ip_ddos_protection_plan_id: The ID of the DDoS protection plan for public IPs (optional, required if ddos_protection_mode is "Enabled") (string).
- firewall_threat_intelligence_mode: The mode of threat intelligence for the firewall (string).
- firewall_intrusion_detection_mode: The mode of intrusion detection (e.g., "Alert" or "Deny") (optional, defaults to "Alert") (string).
- firewall_dns_proxy_enabled: Indicates whether the DNS proxy is enabled for the firewall (bool).
- firewall_dns_servers**: A list of DNS servers configured for the firewall (list of strings).
- firewall_intrusion_detection_private_ranges: A list of private IP ranges for intrusion detection (optional, defaults to an empty list) (list of strings).
- firewall_custom_ip_configurations: A list of custom IP configurations to add to the firewall (optional, defaults to an empty list).
  - name: The name of the IP configuration (string).
  - public_ip_address_id: The ID of the public IP address (string).
- firewall_intrusion_detection_signature_overrides: A list of firewall intrusion detection signature overrides (optional, defaults to an empty list).
  - id: The signature ID (string).
  - state: The override state for the signature (string).
- firewall_intrusion_detection_traffic_bypass: A list of rules for bypassing intrusion detection (optional, defaults to an empty list).
  - name: The name of the bypass rule (string).
  - protocol: The network protocol (e.g., "TCP", "UDP") (string).
  - description: A description of the bypass rule (optional) (string).
  - source_addresses: A list of source IP addresses (optional, defaults to an empty list) (list of strings).
  - source_ip_groups: A list of source IP groups (optional, defaults to an empty list) (list of strings).
  - destination_addresses: A list of destination IP addresses (optional, defaults to an empty list) (list of strings).
  - destination_ports: A list of destination ports (optional, defaults to an empty list) (list of strings).
  - destination_ip_groups: A list of destination IP groups (optional, defaults to an empty list) (list of strings).
- firewall_intrusion_detection_tls_certificate: A list of TLS certificates for intrusion detection (optional, defaults to an empty list).
  - key_vault_secret_id: The Key Vault secret ID storing the certificate (string).
  - name: The name of the TLS certificate (string).
DESCRIPTION
}

variable "hub_bgp_peers" {
  type = map(object({
    virtual_hub_id     = string
    name               = string
    peer_asn           = number
    peer_ip            = string
    vnet_connection_id = string
  }))
  default     = {}
  description = <<DESCRIPTION
This variable defines the configuration for BGP peers.
- virtual_hub_id: The ID of the virtual hub (string).
- name: The name of the BGP peer (string).
- peer_asn: The ASN of the BGP peer (number).
- peer_ip: The IP address of the BGP peer (string).
- vnet_connection_id: The ID of the VNET Hub connection (string).
DESCRIPTION
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the resource."
}
