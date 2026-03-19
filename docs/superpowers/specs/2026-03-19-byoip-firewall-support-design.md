# Design: Bring Your Own IP (BYOIP) Firewall Support

**Date:** 2026-03-19
**Branch:** feature/byoip-support
**Status:** Approved

## Problem

The module currently supports two firewall IP configuration modes:

1. **Classic**: Azure-managed IPs via `azurerm_firewall` with a `public_ip_count` slider.
2. **Module-managed prefix**: The module creates an `azurerm_public_ip_prefix` and individual `azurerm_public_ip` resources, assigned to the firewall via `azapi_resource`.

A third mode -- using only externally managed public IPs (`firewall_custom_ip_configurations`) without any module-created IPs or prefix -- does not work correctly. The root cause is that `firewall_public_ip_prefix_length` defaults to `0`, and `0 != null` evaluates to `true` in Terraform, causing an `azurerm_public_ip_prefix` resource to be created with an invalid prefix length of 0.

## Solution

Fix the conditional logic so that three IP modes are correctly supported, while keeping the existing variable interface intact.

### IP Modes

| Mode | Variables | Resources created |
|---|---|---|
| Classic | `firewall_classic_ip_config = true`, `firewall_public_ip_count = N` | `azurerm_firewall` with `public_ip_count` |
| Prefix (AzAPI) | `firewall_classic_ip_config = false`, `firewall_public_ip_prefix_length = N` | `azurerm_public_ip_prefix`, `azurerm_public_ip` (N IPs), `azapi_resource.firewall` |
| BYOIP only (AzAPI) | `firewall_classic_ip_config = false`, only `firewall_custom_ip_configurations` | `azapi_resource.firewall` (no module-managed IPs) |
| Prefix + BYOIP (AzAPI) | `firewall_classic_ip_config = false`, `firewall_public_ip_prefix_length = N`, plus `firewall_custom_ip_configurations` | `azurerm_public_ip_prefix`, `azurerm_public_ip` (N IPs), `azapi_resource.firewall` with both module and custom IPs |

Classic mode cannot be combined with custom IPs or prefix. The AzAPI path supports prefix, custom IPs, or both.

### Changes

#### 1. Variable defaults

**`variables.tf` (root) and `modules/vhub/variables.tf`:**

- `firewall_public_ip_prefix_length`: default changes from `0` to `null`.

This is technically a breaking change, but `0` was never a valid Azure prefix length and could not have been used in production.

#### 2. Helper locals

**`modules/vhub/local.tf`:**

Replace the current `total_ips` calculation with explicit mode booleans:

```hcl
locals {
  ip_mode_classic = var.firewall_deploy && var.firewall_classic_ip_config
  ip_mode_azapi   = var.firewall_deploy && !var.firewall_classic_ip_config
  deploy_prefix   = local.ip_mode_azapi && var.firewall_public_ip_prefix_length != null

  total_ips = local.deploy_prefix ? pow(2, 32 - var.firewall_public_ip_prefix_length) : 0

  firewall_id = var.firewall_deploy ? (
    local.ip_mode_classic ? azurerm_firewall.this[0].id : azapi_resource.firewall[0].id
  ) : null

  firewall_public_ip_addresses = var.firewall_deploy ? (
    local.ip_mode_classic ? (
      try(azurerm_firewall.this[0].virtual_hub[0].public_ip_addresses, [])
    ) : (
      [for pip in azurerm_public_ip.this : pip.ip_address]
    )
  ) : []
}
```

#### 3. Resource counts

**`modules/vhub/main.tf`:**

| Resource | New count |
|---|---|
| `azurerm_firewall.this` | `local.ip_mode_classic ? 1 : 0` |
| `azurerm_public_ip_prefix.this` | `local.deploy_prefix ? 1 : 0` |
| `azurerm_public_ip.this` | `local.deploy_prefix ? local.total_ips : 0` |
| `azapi_resource.firewall` | `local.ip_mode_azapi ? 1 : 0` |

The `ipConfigurations` in `azapi_resource.firewall` continues to use `concat()` of module-managed IPs and custom IPs. In BYOIP-only mode, the module IPs list is empty.

#### 4. Validations

**`modules/vhub/variables.tf`:**

Three validations:

1. **AzAPI mode requires IP configuration**: When `firewall_deploy = true` and `firewall_classic_ip_config = false`, at least one of `firewall_public_ip_prefix_length` or `firewall_custom_ip_configurations` must be set.

2. **Classic + prefix not combinable** (existing, adapted): `firewall_public_ip_prefix_length` can only be used when `firewall_classic_ip_config = false`. Check changes from `== 0` to `== null`.

3. **Classic + custom IPs not combinable** (new): When `firewall_classic_ip_config = true`, `firewall_custom_ip_configurations` must be empty.

#### 5. New example

**`examples/byoip/main.tf`:**

Demonstrates the BYOIP-only scenario with externally managed public IPs passed via `firewall_custom_ip_configurations`.

#### 6. README update

Document the three IP modes with a brief explanation of when to use each.

## Backward Compatibility

- Teams using classic mode: no change.
- Teams using prefix mode with an explicit `firewall_public_ip_prefix_length`: no change.
- Teams using custom IPs alongside prefix: no change (concat still works).
- The default change from `0` to `null` for `firewall_public_ip_prefix_length` affects no real deployments since `0` was never a valid Azure prefix length.

## Files Changed

- `variables.tf` (root)
- `modules/vhub/variables.tf`
- `modules/vhub/local.tf`
- `modules/vhub/main.tf`
- `examples/byoip/main.tf` (new)
- `README.md`
