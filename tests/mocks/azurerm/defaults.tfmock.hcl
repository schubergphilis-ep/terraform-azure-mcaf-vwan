# Shared mock resource defaults for azurerm provider.
# These provide valid Azure resource IDs so the mocked provider
# does not generate random strings that fail resource ID validation.

mock_resource "azurerm_virtual_wan" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualWans/test-vwan"
  }
}

mock_resource "azurerm_virtual_hub" {
  defaults = {
    id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualHubs/test-hub"
    default_route_table_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualHubs/test-hub/hubRouteTables/defaultRouteTable"
    virtual_router_asn     = 65515
    virtual_router_ips     = ["10.0.0.68", "10.0.0.69"]
  }
}

mock_resource "azurerm_firewall" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/azureFirewalls/test-fw"
  }
}

mock_resource "azurerm_firewall_policy" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/firewallPolicies/test-fwp"
  }
}

mock_resource "azurerm_public_ip_prefix" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPPrefixes/test-fw-pip-prefix"
  }
}

mock_resource "azurerm_public_ip" {
  defaults = {
    id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/publicIPAddresses/test-fw-pip"
    ip_address = "20.0.0.1"
  }
}

mock_resource "azurerm_virtual_hub_routing_intent" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualHubs/test-hub/routingIntent/test-ri"
  }
}
