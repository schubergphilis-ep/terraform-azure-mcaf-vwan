# Tests for BYOIP-only mode: only externally managed custom IPs, no module-created IPs.
# Uses firewall_classic_ip_config = false with only firewall_custom_ip_configurations.

mock_provider "azurerm" {
  override_during = plan
  source          = "./tests/mocks/azurerm"
}

mock_provider "azapi" {
  override_during = plan
  source          = "./tests/mocks/azapi"
}

variables {
  resource_group_name = "test-rg"
  location            = "eastus"

  virtual_wan = {
    name = "test-vwan"
  }
}

run "byoip_only_mode" {
  command = plan

  variables {
    virtual_hubs = {
      hub1 = {
        virtual_hub_name                  = "test-hub"
        location                          = "eastus"
        address_prefix                    = "10.0.0.0/16"
        routing_intent_name               = "test-ri"
        firewall_name                     = "test-fw"
        firewall_policy_name              = "test-fwp"
        firewall_sku_tier                 = "Standard"
        firewall_threat_intelligence_mode = "Alert"
        firewall_dns_servers              = []
        firewall_deploy                   = true
        firewall_classic_ip_config        = false
        firewall_custom_ip_configurations = [
          {
            name                 = "byoip-1"
            public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/pip-1"
          }
        ]
      }
    }
  }

  assert {
    condition     = module.vhub["hub1"].firewall_id != null
    error_message = "Firewall should be deployed in BYOIP-only mode."
  }

  assert {
    condition     = module.vhub["hub1"].firewall_policy_id != null
    error_message = "Firewall policy should be created in BYOIP-only mode."
  }

  # In BYOIP-only mode, the module does not manage IPs so this should be empty
  assert {
    condition     = length(module.vhub["hub1"].firewall_public_ip_addresses) == 0
    error_message = "BYOIP-only mode should return empty firewall_public_ip_addresses."
  }
}

run "byoip_multiple_custom_ips" {
  command = plan

  variables {
    virtual_hubs = {
      hub1 = {
        virtual_hub_name                  = "test-hub"
        location                          = "eastus"
        address_prefix                    = "10.0.0.0/16"
        routing_intent_name               = "test-ri"
        firewall_name                     = "test-fw"
        firewall_policy_name              = "test-fwp"
        firewall_sku_tier                 = "Standard"
        firewall_threat_intelligence_mode = "Alert"
        firewall_dns_servers              = []
        firewall_deploy                   = true
        firewall_classic_ip_config        = false
        firewall_custom_ip_configurations = [
          {
            name                 = "byoip-1"
            public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/pip-1"
          },
          {
            name                 = "byoip-2"
            public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/pip-2"
          },
          {
            name                 = "byoip-3"
            public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/pip-3"
          }
        ]
      }
    }
  }

  assert {
    condition     = module.vhub["hub1"].firewall_id != null
    error_message = "Firewall should be deployed with multiple BYOIP custom IPs."
  }

  assert {
    condition     = length(module.vhub["hub1"].firewall_public_ip_addresses) == 0
    error_message = "BYOIP-only mode should return empty firewall_public_ip_addresses even with multiple custom IPs."
  }
}
