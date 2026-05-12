# This Terraform configuration defines resources for an Azure Virtual Hub setup, including:
# - azurerm_virtual_hub: Represents a Virtual Hub in Azure Virtual WAN.
# - azurerm_virtual_hub_routing_intent: Defines routing policies for the Virtual Hub.
# - azurerm_firewall: Configures an Azure Firewall associated with the Virtual Hub.
# - azurerm_firewall_policy: Specifies the Firewall Policy for the Azure Firewall.
data "azurerm_client_config" "current" {}

resource "azurerm_virtual_hub" "this" {
  name                = var.virtual_hub_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_prefix      = var.address_prefix
  virtual_wan_id      = var.virtual_wan_id

  tags = merge(var.tags, { "Resource Type" = "Virtual Hub" })
}

resource "azurerm_firewall" "this" {
  count = local.ip_mode_classic ? 1 : 0

  name                = var.firewall_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_Hub"
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.this[0].id #checkov:skip=CKV_AZURE_216:The default is set to 'Deny' in the parent module.
  zones               = var.firewall_zones

  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.this.id
    public_ip_count = var.firewall_public_ip_count
  }

  tags = merge(var.tags, { "Resource Type" = "Firewall" })
}

resource "azurerm_public_ip_prefix" "this" {
  count = local.deploy_prefix ? 1 : 0

  name                = "${var.firewall_name}-pip-prefix"
  location            = var.location
  resource_group_name = var.resource_group_name
  zones               = var.firewall_zones

  prefix_length = var.firewall_public_ip_prefix_length

  tags = merge(var.tags, { "Resource Type" = "Public IP Prefix" })
}

resource "azurerm_public_ip" "this" {
  count = local.ip_mode_azapi ? local.total_ips : 0

  name                    = "${var.firewall_name}-pip-${count.index + 1}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  allocation_method       = "Static"
  sku                     = "Standard"
  zones                   = var.firewall_zones
  public_ip_prefix_id     = var.firewall_public_ip_prefix_length != null ? azurerm_public_ip_prefix.this[0].id : null
  ddos_protection_mode    = var.firewall_public_ip_ddos_protection_mode
  ddos_protection_plan_id = var.firewall_public_ip_ddos_protection_plan_id

  tags = merge(var.tags, var.firewall_public_ip_tags, { "Resource Type" = "Public IP" })
}

resource "azapi_resource" "firewall" {
  count = local.ip_mode_azapi ? 1 : 0

  type     = "Microsoft.Network/azureFirewalls@2024-05-01"
  name     = var.firewall_name
  location = var.location
  tags     = merge(var.tags, { "Resource Type" = "Firewall" })

  body = {
    properties = {
      virtualHub = {
        id = azurerm_virtual_hub.this.id
      }
      sku = {
        name = "AZFW_Hub"
        tier = var.firewall_sku_tier
      }
      ipConfigurations = concat(
        [
          for i, pip in azurerm_public_ip.this : {
            name = "${var.firewall_name}-pip-${i + 1}"
            properties = {
              publicIPAddress = {
                id = pip.id
              }
            }
          }
        ],
        [
          for custom_ip in var.firewall_custom_ip_configurations : {
            name = custom_ip.name
            properties = {
              publicIPAddress = {
                id = custom_ip.public_ip_address_id
              }
            }
          }
        ]
      )
      firewallPolicy = {
        id = azurerm_firewall_policy.this[0].id
      }
    }
    zones = var.firewall_zones
  }

  schema_validation_enabled = false
  parent_id                 = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  depends_on = [azurerm_virtual_hub.this, azurerm_public_ip.this]
}

resource "azurerm_firewall_policy" "this" {
  count = var.firewall_deploy ? 1 : 0

  name                     = var.firewall_policy_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.firewall_sku_tier
  threat_intelligence_mode = var.firewall_threat_intelligence_mode

  dynamic "intrusion_detection" {
    for_each = var.firewall_sku_tier == "Premium" ? [1] : []

    content {
      mode           = var.firewall_intrusion_detection_mode
      private_ranges = try(var.firewall_intrusion_detection_private_ranges, [])

      dynamic "signature_overrides" {
        for_each = try(var.firewall_intrusion_detection_signature_overrides, [])
        content {
          id    = signature_overrides.value.id
          state = signature_overrides.value.state
        }
      }

      dynamic "traffic_bypass" {
        for_each = try(var.firewall_intrusion_detection_traffic_bypass, [])

        content {
          name                  = traffic_bypass.value.name
          protocol              = traffic_bypass.value.protocol
          description           = try(traffic_bypass.value.description, null)
          source_addresses      = try(traffic_bypass.value.source_addresses, [])
          source_ip_groups      = try(traffic_bypass.value.source_ip_groups, [])
          destination_addresses = try(traffic_bypass.value.destination_addresses, [])
          destination_ports     = try(traffic_bypass.value.destination_ports, [])
          destination_ip_groups = try(traffic_bypass.value.destination_ip_groups, [])
        }
      }
    }
  }

  dynamic "tls_certificate" {
    for_each = var.firewall_sku_tier == "Premium" && var.firewall_intrusion_detection_tls_certificate != null ? [var.firewall_intrusion_detection_tls_certificate] : []

    content {
      key_vault_secret_id = tls_certificate.value.key_vault_secret_id
      name                = tls_certificate.value.name
    }
  }

  dns {
    proxy_enabled = var.firewall_dns_proxy_enabled
    servers       = var.firewall_dns_servers
  }

  dynamic "insights" {
    for_each = var.firewall_insights_enabled ? [1] : []

    content {
      enabled                            = var.firewall_insights_enabled
      default_log_analytics_workspace_id = provider::azurerm::normalise_resource_id(var.firewall_insights_default_log_analytics_workspace_id)

      retention_in_days = var.firewall_insights_retention_in_days

      dynamic "log_analytics_workspace" {
        for_each = var.firewall_insights_log_analytics_workspaces

        content {
          id                = provider::azurerm::normalise_resource_id(log_analytics_workspace.value.id)
          firewall_location = log_analytics_workspace.value.firewall_location
        }
      }
    }
  }

  tags = merge(var.tags, { "Resource Type" = "Firewall Policy" })
}

resource "azurerm_virtual_hub_routing_intent" "this" {
  count = var.firewall_deploy && var.enable_routing_intent ? 1 : 0

  name           = var.routing_intent_name
  virtual_hub_id = azurerm_virtual_hub.this.id

  routing_policy {
    name         = "_policy_PublicTraffic"
    destinations = ["Internet"]
    next_hop     = local.firewall_id
  }
  routing_policy {
    name         = "_policy_PrivateTraffic"
    destinations = ["PrivateTraffic"]
    next_hop     = local.firewall_id
  }
  depends_on = [azurerm_firewall_policy.this, azapi_resource.firewall, azurerm_firewall.this]
}
