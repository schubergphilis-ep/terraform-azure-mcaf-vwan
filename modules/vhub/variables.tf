variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the VWAN will be created"
}

variable "virtual_hub_name" {
  type        = string
  description = "The name of the virtual hub."
  validation {
    condition     = length(var.virtual_hub_name) > 0
    error_message = "virtual_hub_name must not be empty."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where the virtual hub is deployed."
}

variable "address_prefix" {
  type        = string
  description = "The IP address prefix assigned to the virtual hub (e.g., '10.0.0.0/16')."
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+/\\d+$", var.address_prefix))
    error_message = "address_prefix must be a valid CIDR string (e.g., '10.0.0.0/16')."
  }
}

variable "enable_routing_intent" {
  type        = bool
  description = "Indicates wheter or not to configure routing intent."
}

variable "routing_intent_name" {
  type        = string
  description = "The name of the routing intent associated with the virtual hub."
}

variable "firewall_name" {
  type        = string
  description = "The name of the Azure Firewall deployed within the virtual hub."
}

variable "firewall_zones" {
  type        = set(string)
  description = "Availability zones where the firewall is deployed (e.g., ['1', '2', '3'])."
}

variable "firewall_policy_name" {
  type        = string
  description = "The name of the firewall policy applied to the Azure Firewall."
}

variable "firewall_sku_tier" {
  type        = string
  description = "The SKU tier of the firewall (e.g. 'Basic', 'Standard' or 'Premium')."

  validation {
    condition     = alltrue([!var.firewall_deploy || contains(["Basic", "Standard", "Premium"], var.firewall_sku_tier)])
    error_message = "When firewall_deploy is true, the firewall_sku_tier must be either 'Basic', 'Standard' or 'Premium'."
  }
}

variable "firewall_public_ip_count" {
  type        = number
  default     = null
  description = "The number of public IPs allocated to the firewall. Required if firewall_public_ip_prefix_id is not set."
}

variable "firewall_public_ip_prefix_length" {
  type        = number
  default     = 0
  description = "The public ip prefix length that will be requested for the firewall. Required if firewall_public_ip_count is not set."

  validation {
    condition     = var.firewall_public_ip_prefix_length == 0 || !var.firewall_classic_ip_config
    error_message = "firewall_public_ip_prefix_length can only be used when firewall_classic_ip_config is set to false."
  }
}

variable "firewall_public_ip_ddos_protection_mode" {
  type        = string
  default     = "VirtualNetworkInherited"
  description = "The DDoS protection mode for the public IP. Possible values are Disabled, Enabled, and VirtualNetworkInherited."

  validation {
    condition     = contains(["Disabled", "Enabled", "VirtualNetworkInherited"], var.firewall_public_ip_ddos_protection_mode)
    error_message = "The ddos_protection_mode must be one of 'Disabled', 'Enabled', or 'VirtualNetworkInherited'."
  }
}

variable "firewall_public_ip_ddos_protection_plan_id" {
  type        = string
  default     = null
  description = "The ID of the DDoS protection plan to be attached to the public IP. Required if ddos_protection_mode is Enabled."
}

variable "firewall_threat_intelligence_mode" {
  type        = string
  description = "The mode of threat intelligence for the firewall (e.g., 'Alert', 'Deny', or 'Off')."
  validation {
    condition     = contains(["Alert", "Deny", "Off"], var.firewall_threat_intelligence_mode)
    error_message = "firewall_threat_intelligence_mode must be 'Alert', 'Deny', or 'Off'."
  }
}

variable "firewall_intrusion_detection_mode" {
  type        = string
  default     = "Alert"
  description = "The mode of intrusion detection (e.g., 'Alert', 'Deny' or 'Off')."
  validation {
    condition     = contains(["Alert", "Deny", "Off"], var.firewall_intrusion_detection_mode)
    error_message = "firewall_intrusion_detection_mode must be 'Alert', 'Deny' or 'Off'."
  }
}

variable "firewall_dns_proxy_enabled" {
  type        = bool
  description = "Indicates whether the DNS proxy is enabled for the firewall."
}

variable "firewall_dns_servers" {
  type        = list(string)
  description = "A list of DNS servers configured for the firewall."
}

variable "firewall_intrusion_detection_private_ranges" {
  type        = list(string)
  default     = []
  description = "A list of private IP ranges for intrusion detection."
}

variable "firewall_intrusion_detection_signature_overrides" {
  type = list(object({
    id    = string
    state = string
  }))
  default     = []
  description = "A list of firewall intrusion detection signature overrides."
}

variable "firewall_intrusion_detection_traffic_bypass" {
  type = list(object({
    name                  = string
    protocol              = string
    description           = optional(string)
    source_addresses      = optional(list(string), [])
    source_ip_groups      = optional(list(string), [])
    destination_addresses = optional(list(string), [])
    destination_ports     = optional(list(string), [])
    destination_ip_groups = optional(list(string), [])
  }))
  default     = []
  description = "A list of rules for bypassing intrusion detection."
}

variable "firewall_intrusion_detection_tls_certificate" {
  type = object({
    key_vault_secret_id = string
    name                = string
  })
  default     = null
  description = "TLS certificate used for intrusion detection (stored in Key Vault)."
}

variable "virtual_wan_id" {
  type        = string
  description = "The ID of the virtual WAN."
}

variable "firewall_deploy" {
  type        = bool
  default     = true
  description = "Controls whether to deploy an Azure Firewall in the Virtual Hub"
}

variable "firewall_classic_ip_config" {
  type        = bool
  default     = false
  description = "Controls whether to use classic IP configuration for the firewall."
}

variable "firewall_custom_ip_configurations" {
  type = list(object({
    name                 = string
    public_ip_address_id = string
  }))
  default     = []
  description = "List of custom IP configurations to add to the firewall. Each object must contain 'name' and 'public_ip_address_id'."
}

variable "firewall_insights_enabled" {
  type        = bool
  default     = false
  description = "Whether the insights functionality is enabled for this Firewall Policy."
}

variable "firewall_insights_default_log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "The ID of the default Log Analytics Workspace that the Firewalls associated with this Firewall Policy will send their logs to, when there is no location matches in the log_analytics_workspace."
}

variable "firewall_insights_retention_in_days" {
  type        = number
  default     = null
  description = "The log retention period in days for firewall insights."
}

variable "firewall_insights_log_analytics_workspaces" {
  type = list(object({
    id                = string
    firewall_location = string
  }))
  default     = []
  description = "A list of log_analytics_workspace blocks. Each object must contain 'id' (the Log Analytics Workspace ID) and 'firewall_location' (the location of the Firewalls)."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the resource."
}
