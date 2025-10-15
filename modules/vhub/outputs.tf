output "firewall_id" {
  description = "The ID of the Firewall within the Virtual Hub."
  value       = var.firewall_deploy ? local.firewall_id : null
}

output "firewall_policy_id" {
  description = "The ID of the Firewall Policy within the Virtual Hub."
  value       = var.firewall_deploy ? azurerm_firewall_policy.this[0].id : null
}

output "firewall_public_ip_addresses" {
  description = "The public IP addresses of the Firewall."
  value       = local.firewall_public_ip_addresses
}

output "vhub_id" {
  description = "The ID of the Virtual WAN within which the Virtual Hub exists."
  value       = azurerm_virtual_hub.this.id
}

output "vhub_name" {
  description = "The name of the Virtual Hub."
  value       = azurerm_virtual_hub.this.name
}

output "default_route_table_id" {
  description = "The ID of the default Route Table in the Virtual Hub."
  value       = azurerm_virtual_hub.this.default_route_table_id
}

output "virtual_router_asn" {
  description = "The Autonomous System Number of the Virtual Hub BGP router."
  value       = azurerm_virtual_hub.this.virtual_router_asn
}

output "virtual_router_ips" {
  description = "The IP addresses of the Virtual Hub BGP router."
  value       = azurerm_virtual_hub.this.virtual_router_ips
}

output "address_prefix" {
  description = "The Address Prefix used for this Virtual Hub."
  value       = azurerm_virtual_hub.this.address_prefix
}

output "routing_intent_id" {
  description = "The ID of the routing intent for this Virtual Hub."
  value       = var.firewall_deploy && var.enable_routing_intent ? azurerm_virtual_hub_routing_intent.this[0].id : null
}
