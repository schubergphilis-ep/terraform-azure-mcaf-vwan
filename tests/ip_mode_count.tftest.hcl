# Tests for Count/AzAPI IP mode: individual public IPs without prefix.
# Uses firewall_classic_ip_config = false with firewall_public_ip_count.

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

run "count_mode_creates_individual_ips" {
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
        firewall_public_ip_count          = 2
      }
    }
  }

  assert {
    condition     = module.vhub["hub1"].firewall_id != null
    error_message = "Firewall should be deployed in count/AzAPI mode."
  }

  assert {
    condition     = module.vhub["hub1"].firewall_policy_id != null
    error_message = "Firewall policy should be created."
  }
}

run "count_mode_with_custom_ips" {
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
        firewall_public_ip_count          = 1
        firewall_custom_ip_configurations = [
          {
            name                 = "custom-ip-1"
            public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Network/publicIPAddresses/pip-1"
          }
        ]
      }
    }
  }

  assert {
    condition     = module.vhub["hub1"].firewall_id != null
    error_message = "Firewall should be deployed with count + custom IPs."
  }
}
