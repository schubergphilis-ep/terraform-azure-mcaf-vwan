locals {
  ip_mode_classic = var.firewall_deploy && var.firewall_classic_ip_config
  ip_mode_azapi   = var.firewall_deploy && !var.firewall_classic_ip_config
  deploy_prefix   = local.ip_mode_azapi && var.firewall_public_ip_prefix_length != null

  # In AzAPI mode, calculate total module-managed IPs:
  # - prefix_length set: all IPs from the prefix (e.g. /30 = 4 IPs)
  #   Note: Azure Public IP Prefix allocates ALL addresses as usable IPs,
  #   unlike subnets which reserve network/broadcast addresses.
  # - public_ip_count set (no prefix): that many individual IPs
  # - neither set: 0 (BYOIP only mode)
  total_ips = local.ip_mode_azapi ? (
    var.firewall_public_ip_prefix_length != null ? pow(2, 32 - var.firewall_public_ip_prefix_length) : (
      var.firewall_public_ip_count != null ? var.firewall_public_ip_count : 0
    )
  ) : 0

  firewall_id = var.firewall_deploy ? (
    local.ip_mode_classic ? azurerm_firewall.this[0].id : azapi_resource.firewall[0].id
  ) : null

  # In BYOIP-only mode this returns [] because the module does not manage
  # those IPs and only has resource IDs, not resolved addresses.
  # Consumers deploying BYOIP firewalls know their own IP addresses.
  firewall_public_ip_addresses = var.firewall_deploy ? (
    local.ip_mode_classic ? (
      try(azurerm_firewall.this[0].virtual_hub[0].public_ip_addresses, [])
      ) : (
      [for pip in azurerm_public_ip.this : pip.ip_address]
    )
  ) : []
}
