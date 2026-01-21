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

resource "azurerm_network_ddos_protection_plan" "example" {
  name                = "example-ddos-plan"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_public_ip" "example" {
  name                = "example-public-ip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_key_vault" "example" {
  name                        = "example-kv"
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = "afabd4df-1be9-48bc-8ecc-902a3cdda530"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_log_analytics_workspace" "default" {
  name                = "default-law"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_workspace" "westeurope" {
  name                = "westeurope-law"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "vwan" {
  source = "../../"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  virtual_wan = {
    name                              = "example-virtual-wan"
    type                              = "Standard"
    disable_vpn_encryption            = false
    allow_branch_to_branch_traffic    = true
    office365_local_breakout_category = "OptimizeAndAllow"
  }

  virtual_hubs = {
    hub1 = {
      virtual_hub_name                            = "example-virtual-hub"
      location                                    = "eastus"
      address_prefix                              = "10.0.0.0/16"
      routing_intent_name                         = "example-routing-intent"
      firewall_name                               = "example-firewall"
      firewall_zones                              = ["1", "2", "3"]
      firewall_policy_name                        = "example-firewall-policy"
      firewall_sku_tier                           = "Premium"
      firewall_public_ip_ddos_protection_mode     = "Enabled"
      firewall_public_ip_ddos_protection_plan_id  = azurerm_network_ddos_protection_plan.example.id
      firewall_public_ip_prefix_length            = 30
      firewall_threat_intelligence_mode           = "Alert"
      firewall_dns_proxy_enabled                  = true
      firewall_dns_servers                        = ["8.8.8.8", "8.8.4.4"]
      firewall_deploy                             = true
      firewall_classic_ip_config                  = false
      firewall_intrusion_detection_mode           = "Deny"
      firewall_intrusion_detection_private_ranges = ["10.0.0.0/28"]
      firewall_custom_ip_configurations = [
        {
          name                 = "CustomIPConfig1"
          public_ip_address_id = azurerm_public_ip.example.id
        }
      ]
      firewall_intrusion_detection_signature_overrides = [
        {
          id    = "2024898"
          state = "Alert"
        }
      ]
      firewall_intrusion_detection_traffic_bypass = [
        {
          name                  = "SecretBypass"
          protocol              = "TCP"
          description           = "Example bypass rule"
          source_addresses      = ["*"]
          destination_addresses = ["*"]
          destination_ports     = ["443"]
        }
      ]
      firewall_intrusion_detection_tls_certificate = {
        key_vault_secret_id = "${azurerm_key_vault.example.id}/secrets/example-cert"
        name                = "certname"
      }
      firewall_insights_enabled                            = true
      firewall_insights_default_log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id
      firewall_insights_retention_in_days                  = 30
      firewall_insights_log_analytics_workspaces = [
        {
          id                = azurerm_log_analytics_workspace.westeurope.id
          firewall_location = "westeurope"
        }
      ]
    }
  }

  hub_bgp_peers = {
    # In a real environment, you would use actual IDs like:
    # peer1 = {
    #   virtual_hub_id     = module.vwan.virtual_hub_ids["hub1"]
    #   name               = "example-peer"
    #   peer_asn           = 65001
    #   peer_ip            = "10.0.1.1"
    #   vnet_connection_id = azurerm_virtual_hub_connection.example.id
    # }
  }

  tags = {
    "Environment"   = "Production"
    "Resource Type" = "Virtual WAN"
  }
}

# Example of how you would create a Virtual Hub connection in a real environment
# resource "azurerm_virtual_hub_connection" "example" {
#   name                      = "example-hub-connection"
#   virtual_hub_id            = module.vwan.virtual_hub_ids["hub1"]
#   remote_virtual_network_id = azurerm_virtual_network.example.id
# }
