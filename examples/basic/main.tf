terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = "example-resource-group"
  location = "eastus"
  tags = {
    "Environment"   = "Production"
    "Resource Type" = "Resource Group"
  }
}

module "vwan" {
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  virtual_wan = {
    name = "example-virtual-wan"
    # Optional parameters with defaults:
    # type = "Standard"
    # disable_vpn_encryption = false
    # allow_branch_to_branch_traffic = true
    # office365_local_breakout_category = "None"
  }

  virtual_hubs = {
    hub1 = {
      virtual_hub_name                  = "example-virtual-hub"
      location                          = "eastus"
      address_prefix                    = "10.0.0.0/16"
      routing_intent_name               = "example-routing-intent"
      firewall_name                     = "example-firewall"
      firewall_policy_name              = "example-firewall-policy"
      firewall_sku_tier                 = "Standard"
      firewall_threat_intelligence_mode = "Alert"
      firewall_dns_servers              = ["8.8.8.8", "8.8.4.4"]
      firewall_public_ip_count          = 1
      # Optional parameters with defaults:
      # firewall_deploy = true
      # firewall_classic_ip_config = false
      # firewall_zones = ["1", "2", "3"]
      # firewall_public_ip_prefix_length = null
      # firewall_public_ip_ddos_protection_mode = "VirtualNetworkInherited"
      # firewall_public_ip_ddos_protection_plan_id = null
      # firewall_intrusion_detection_mode = "Alert"
      # firewall_dns_proxy_enabled = true
      # firewall_intrusion_detection_private_ranges = []
    }
  }

  hub_bgp_peers = {
    peer1 = {
      virtual_hub_id     = "example-virtual-hub-id" # This should be a reference to your hub's actual ID in production
      name               = "example-peer"
      peer_asn           = 65001
      peer_ip            = "10.0.1.1"
      vnet_connection_id = "example-vnet-id" # This should be a reference to your connection's actual ID in production
    }
  }

  tags = {
    "Environment"   = "Production"
    "Resource Type" = "Virtual WAN"
  }
}
