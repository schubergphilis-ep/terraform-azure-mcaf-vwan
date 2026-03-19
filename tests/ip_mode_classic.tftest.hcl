# Tests for Classic IP mode: azurerm_firewall with public_ip_count slider.
# Classic mode uses firewall_classic_ip_config = true and requires firewall_public_ip_count.

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

run "classic_mode_with_ip_count" {
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
        firewall_classic_ip_config        = true
        firewall_public_ip_count          = 3
      }
    }
  }

  assert {
    condition     = module.vhub["hub1"].firewall_id != null
    error_message = "Firewall should be deployed in classic mode."
  }

  assert {
    condition     = module.vhub["hub1"].firewall_policy_id != null
    error_message = "Firewall policy should be created."
  }
}

run "classic_mode_no_firewall" {
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
        firewall_deploy                   = false
        firewall_classic_ip_config        = true
      }
    }
  }

  assert {
    condition     = module.vhub["hub1"].firewall_id == null
    error_message = "No firewall should be deployed when firewall_deploy is false."
  }

  assert {
    condition     = module.vhub["hub1"].firewall_policy_id == null
    error_message = "No firewall policy should be created when firewall_deploy is false."
  }
}
