output "resource_group_id" {
  description = "ID of the Resource Group created by the module"
  value       = var.create_new_resource_group ? azurerm_resource_group.this[0].id : null
}

output "virtual_wan" {
  description = "output the resource of the vwan"
  value       = azurerm_virtual_wan.this
}

output "virtual_wan_id" {
  description = "ID of the Virtual wan created by the module"
  value       = azurerm_virtual_wan.this.id
}

output "vhub_ids" {
  description = "Map of IDs of the Virtual Hubs created by the module"
  value = {
    for k, v in module.vhub : k => v.vhub_id
  }
}

output "vhub_names" {
  description = "Map of names of the Virtual Hubs created by the module"
  value = {
    for k, v in module.vhub : k => v.vhub_name
  }
}

output "vhub_firewall_ids" {
  description = "Map of IDs of the Firewalls created in each Virtual Hub"
  value = {
    for k, v in module.vhub : k => v.firewall_id
  }
}

output "vhub_firewall_policy_ids" {
  description = "Map of IDs of the Firewall Policies created in each Virtual Hub"
  value = {
    for k, v in module.vhub : k => v.firewall_policy_id
  }
}

output "vhub_firewall_public_ip_addresses" {
  description = "Map of public IP addresses of the Firewalls created in each Virtual Hub"
  value = {
    for k, v in module.vhub : k => v.firewall_public_ip_addresses if length(v.firewall_public_ip_addresses) > 0
  }
}

output "vhub_default_route_table_ids" {
  description = "Map of IDs of the default Route Tables in each Virtual Hub"
  value = {
    for k, v in module.vhub : k => v.default_route_table_id
  }
}

output "vhub_virtual_router_asns" {
  description = "Map of Autonomous System Numbers of the Virtual Hub BGP routers"
  value = {
    for k, v in module.vhub : k => v.virtual_router_asn
  }
}

output "vhub_virtual_router_ips" {
  description = "Map of IP addresses of the Virtual Hub BGP routers"
  value = {
    for k, v in module.vhub : k => v.virtual_router_ips
  }
}

output "vhub_address_prefixes" {
  description = "Map of Address Prefixes used for each Virtual Hub"
  value = {
    for k, v in module.vhub : k => v.address_prefix
  }
}
