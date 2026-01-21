# This Terraform configuration defines resources and a module for deploying an Azure Virtual WAN setup.
resource "azurerm_resource_group" "this" {
  count = var.create_new_resource_group ? 1 : 0

  name     = var.resource_group_name
  location = var.location

  tags = merge(var.tags, { "Resource Type" = "Resource Group" })
}

resource "azurerm_virtual_wan" "this" {
  resource_group_name               = var.create_new_resource_group ? azurerm_resource_group.this[0].name : var.resource_group_name
  location                          = var.location
  name                              = var.virtual_wan.name
  type                              = var.virtual_wan.type
  disable_vpn_encryption            = var.virtual_wan.disable_vpn_encryption
  allow_branch_to_branch_traffic    = var.virtual_wan.allow_branch_to_branch_traffic
  office365_local_breakout_category = var.virtual_wan.office365_local_breakout_category

  tags = merge(var.tags, { "Resource Type" = "Virtual WAN" })
}

module "vhub" {
  for_each = var.virtual_hubs

  source = "./modules/vhub"

  virtual_wan_id                                       = azurerm_virtual_wan.this.id
  resource_group_name                                  = var.create_new_resource_group ? azurerm_resource_group.this[0].name : var.resource_group_name
  virtual_hub_name                                     = each.value.virtual_hub_name
  location                                             = each.value.location
  address_prefix                                       = each.value.address_prefix
  enable_routing_intent                                = each.value.enable_routing_intent
  routing_intent_name                                  = each.value.routing_intent_name
  firewall_name                                        = each.value.firewall_name
  firewall_zones                                       = each.value.firewall_zones
  firewall_policy_name                                 = each.value.firewall_policy_name
  firewall_sku_tier                                    = each.value.firewall_sku_tier
  firewall_public_ip_count                             = each.value.firewall_public_ip_count
  firewall_public_ip_prefix_length                     = each.value.firewall_public_ip_prefix_length
  firewall_public_ip_ddos_protection_mode              = each.value.firewall_public_ip_ddos_protection_mode
  firewall_public_ip_ddos_protection_plan_id           = each.value.firewall_public_ip_ddos_protection_plan_id
  firewall_threat_intelligence_mode                    = each.value.firewall_threat_intelligence_mode
  firewall_intrusion_detection_mode                    = each.value.firewall_intrusion_detection_mode
  firewall_dns_proxy_enabled                           = each.value.firewall_dns_proxy_enabled
  firewall_dns_servers                                 = each.value.firewall_dns_servers
  firewall_intrusion_detection_private_ranges          = each.value.firewall_intrusion_detection_private_ranges
  firewall_intrusion_detection_signature_overrides     = each.value.firewall_intrusion_detection_signature_overrides
  firewall_intrusion_detection_traffic_bypass          = each.value.firewall_intrusion_detection_traffic_bypass
  firewall_intrusion_detection_tls_certificate         = each.value.firewall_intrusion_detection_tls_certificate
  firewall_deploy                                      = each.value.firewall_deploy
  firewall_classic_ip_config                           = each.value.firewall_classic_ip_config
  firewall_custom_ip_configurations                    = each.value.firewall_custom_ip_configurations
  firewall_insights_enabled                            = each.value.firewall_insights_enabled
  firewall_insights_default_log_analytics_workspace_id = each.value.firewall_insights_default_log_analytics_workspace_id
  firewall_insights_retention_in_days                  = each.value.firewall_insights_retention_in_days
  firewall_insights_log_analytics_workspaces           = each.value.firewall_insights_log_analytics_workspaces

  tags = var.tags
}

resource "azurerm_virtual_hub_bgp_connection" "this" {
  for_each = var.hub_bgp_peers

  virtual_hub_id                = each.value.virtual_hub_id
  name                          = each.value.name
  peer_asn                      = each.value.peer_asn
  peer_ip                       = each.value.peer_ip
  virtual_network_connection_id = each.value.vnet_connection_id
}
