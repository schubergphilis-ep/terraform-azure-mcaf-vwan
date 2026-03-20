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

# Externally managed public IP prefix and IPs (Bring Your Own IP).
# These resources live outside the VWAN module, giving you full control
# over the IP lifecycle -- IPs survive firewall rebuilds, can be shared
# across modules, and are managed by your own Terraform configuration.

resource "azurerm_public_ip_prefix" "firewall" {
  name                = "example-fw-pip-prefix"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  prefix_length       = 30
  zones               = ["1", "2", "3"]

  tags = {
    "Environment" = "Production"
    "Purpose"     = "Firewall"
  }
}

resource "azurerm_public_ip" "firewall" {
  count = 4 # /30 = 4 usable IPs

  name                = "example-fw-pip-${count.index + 1}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  public_ip_prefix_id = azurerm_public_ip_prefix.firewall.id

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

      # BYOIP mode: pass all externally managed IPs to the firewall.
      # No firewall_public_ip_count or firewall_public_ip_prefix_length --
      # the module creates no IPs itself.
      firewall_custom_ip_configurations = [
        for i, pip in azurerm_public_ip.firewall : {
          name                 = "byoip-${i + 1}"
          public_ip_address_id = pip.id
        }
      ]
    }
  }

  tags = {
    "Environment"   = "Production"
    "Resource Type" = "Virtual WAN"
  }
}
