terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "12345678-abcd-1234-efgh-1234567890ab"
}

resource "azurerm_resource_group" "this" {
  name     = "example-resource-group"
  location = "eastus"

  tags = {
    "Environment"   = "Production"
    "Resource Type" = "Resource Group"
  }
}

# Externally managed public IPs (Bring Your Own IP)
resource "azurerm_public_ip" "firewall" {
  count = 2

  name                = "example-fw-pip-${count.index}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    "Environment" = "Production"
    "Purpose"     = "Firewall"
  }
}

module "vwan" {
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  virtual_wan = {
    name = "example-virtual-wan"
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

      # BYOIP mode: no ip_count, no prefix_length, only custom IPs
      firewall_custom_ip_configurations = [
        {
          name                 = "byoip-1"
          public_ip_address_id = azurerm_public_ip.firewall[0].id
        },
        {
          name                 = "byoip-2"
          public_ip_address_id = azurerm_public_ip.firewall[1].id
        },
      ]
    }
  }

  tags = {
    "Environment"   = "Production"
    "Resource Type" = "Virtual WAN"
  }
}
