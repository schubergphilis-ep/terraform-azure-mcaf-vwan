# Tests for validation failures: ensures invalid configurations are rejected.
# Cross-variable validations are on the firewall_deploy variable in the vhub
# submodule. When the root module passes invalid combinations through virtual_hubs,
# the submodule's validation triggers as a failure on module.vhub.

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

run "azapi_mode_requires_ip_source" {
  # When firewall_deploy = true and classic = false, at least one IP source is required.
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
        # No IP source: no count, no prefix, no custom IPs
      }
    }
  }

  expect_failures = [
    var.virtual_hubs,
  ]
}

run "classic_mode_requires_ip_count" {
  # Classic mode with firewall_deploy = true requires firewall_public_ip_count.
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
        # Missing: firewall_public_ip_count
      }
    }
  }

  expect_failures = [
    var.virtual_hubs,
  ]
}

run "classic_mode_rejects_custom_ips" {
  # Classic mode cannot be combined with custom IP configurations.
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

  expect_failures = [
    var.virtual_hubs,
  ]
}

run "classic_mode_rejects_prefix" {
  # Classic mode cannot be combined with IP prefix.
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
        firewall_public_ip_count          = 1
        firewall_public_ip_prefix_length  = 30
      }
    }
  }

  expect_failures = [
    var.virtual_hubs,
  ]
}
