# Design: Bring Your Own IP (BYOIP) Firewall Support

**Date:** 2026-03-19
**Branch:** feature/byoip-support
**Status:** Approved
**Requires:** Terraform >= 1.9 (for cross-variable validation)

## Problem

The module currently supports two firewall IP configuration modes:

1. **Classic**: Azure-managed IPs via `azurerm_firewall` with a `public_ip_count` slider.
2. **Module-managed prefix**: The module creates an `azurerm_public_ip_prefix` and individual `azurerm_public_ip` resources, assigned to the firewall via `azapi_resource`.

A third mode -- using only externally managed public IPs (`firewall_custom_ip_configurations`) without any module-created IPs or prefix -- does not work correctly. The root cause is that `firewall_public_ip_prefix_length` defaults to `0`, and `0 != null` evaluates to `true` in Terraform, causing an `azurerm_public_ip_prefix` resource to be created with an invalid prefix length of 0.

## Solution

Fix the conditional logic so that all IP modes are correctly supported, while keeping the existing variable interface intact.

### IP Modes

| Mode | Variables | Resources created |
|---|---|---|
| Classic | `firewall_classic_ip_config = true`, `firewall_public_ip_count = N` | `azurerm_firewall` with `public_ip_count` |
| Count (AzAPI) | `firewall_classic_ip_config = false`, `firewall_public_ip_count = N` | `azurerm_public_ip` (N individual IPs, no prefix), `azapi_resource.firewall` |
| Prefix (AzAPI) | `firewall_classic_ip_config = false`, `firewall_public_ip_prefix_length = N` | `azurerm_public_ip_prefix`, `azurerm_public_ip` (all IPs from prefix), `azapi_resource.firewall` |
| BYOIP only (AzAPI) | `firewall_classic_ip_config = false`, only `firewall_custom_ip_configurations` | `azapi_resource.firewall` (no module-managed IPs) |

In AzAPI mode, `firewall_custom_ip_configurations` can be combined with prefix or count mode (IPs are concatenated). Classic mode cannot be combined with custom IPs or prefix.

### Changes

#### 1. Variable defaults

**`variables.tf` (root) and `modules/vhub/variables.tf`:**

- `firewall_public_ip_prefix_length`: default changes from `0` to `null`.

This is technically a breaking change, but `0` was never a valid Azure prefix length and could not have been used in production.

#### 2. Helper locals

**`modules/vhub/local.tf`:**

Replace the current locals with explicit mode booleans and clearer IP calculation:

```hcl
locals {
  ip_mode_classic = var.firewall_deploy && var.firewall_classic_ip_config
  ip_mode_azapi   = var.firewall_deploy && !var.firewall_classic_ip_config
  deploy_prefix   = local.ip_mode_azapi && var.firewall_public_ip_prefix_length != null

  # In AzAPI mode, calculate total module-managed IPs:
  # - prefix_length set: all IPs from the prefix (e.g. /30 = 4 IPs)
  #   Note: Azure Public IP Prefix allocates ALL addresses as usable IPs,
  #   unlike subnets which reserve network/broadcast addresses.
  # - public_ip_count set (no prefix): that many individual IPs
  # - neither set: 0 (BYOIP only mode)
  total_ips = local.ip_mode_azapi ? (
    var.firewall_public_ip_prefix_length != null ? pow(2, 32 - var.firewall_public_ip_prefix_length) : (
      var.firewall_public_ip_count != null ? var.firewall_public_ip_count : 0
    )
  ) : 0

  firewall_id = var.firewall_deploy ? (
    local.ip_mode_classic ? azurerm_firewall.this[0].id : azapi_resource.firewall[0].id
  ) : null

  # In BYOIP-only mode this returns [] because the module does not manage
  # those IPs and only has resource IDs, not resolved addresses.
  # Consumers deploying BYOIP firewalls know their own IP addresses.
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
| `azurerm_public_ip.this` | `local.ip_mode_azapi ? local.total_ips : 0` |
| `azapi_resource.firewall` | `local.ip_mode_azapi ? 1 : 0` |

The `ipConfigurations` in `azapi_resource.firewall` continues to use `concat()` of module-managed IPs and custom IPs. In BYOIP-only mode, the module IPs list is empty.

**Unchanged lines confirmed safe:**

- `azurerm_public_ip.this` `public_ip_prefix_id`: The conditional `var.firewall_public_ip_prefix_length != null ? azurerm_public_ip_prefix.this[0].id : null` remains correct. In count-without-prefix mode, `prefix_length` is `null` so `public_ip_prefix_id` is `null`. In BYOIP mode, the resource has count 0 so this line is never evaluated.

- `azapi_resource.firewall` `depends_on`: References `azurerm_public_ip.this` which may have count 0 in BYOIP mode. A `depends_on` referencing a resource with count 0 is a no-op in Terraform -- no change needed.

#### 4. Validations

**`modules/vhub/variables.tf`:**

Four validations (all use cross-variable references, requiring Terraform >= 1.9):

1. **AzAPI mode requires IP configuration**: When `firewall_deploy = true` and `firewall_classic_ip_config = false`, at least one of `firewall_public_ip_prefix_length`, `firewall_public_ip_count`, or `firewall_custom_ip_configurations` must be set.

2. **Classic + prefix not combinable** (existing, adapted): `firewall_public_ip_prefix_length` can only be used when `firewall_classic_ip_config = false`. Check changes from `== 0` to `== null`.

3. **Classic + custom IPs not combinable** (new): When `firewall_classic_ip_config = true`, `firewall_custom_ip_configurations` must be empty.

4. **Classic mode requires public_ip_count** (new): When `firewall_classic_ip_config = true` and `firewall_deploy = true`, `firewall_public_ip_count` must be set (not null). The classic `azurerm_firewall` resource requires an explicit `public_ip_count` value.

#### 5. New example

**`examples/byoip/main.tf`:**

Demonstrates the BYOIP-only scenario with externally managed public IPs passed via `firewall_custom_ip_configurations`.

#### 6. README update

Document the IP modes with a brief explanation of when to use each.

## Backward Compatibility

- Teams using classic mode: no change.
- Teams using prefix mode with an explicit `firewall_public_ip_prefix_length`: no change.
- Teams using count mode (`firewall_public_ip_count` in AzAPI mode): no change, behavior preserved.
- Teams using custom IPs alongside prefix or count: no change (concat still works).
- The default change from `0` to `null` for `firewall_public_ip_prefix_length` affects no real deployments since `0` was never a valid Azure prefix length.
- `firewall_public_ip_addresses` output returns `[]` in BYOIP-only mode. This is by design: the module only has resource IDs for custom IPs, not resolved IP addresses. Consumers deploying BYOIP firewalls manage their own IPs externally and know their addresses.
- **Bug fix:** In AzAPI mode (prefix or count), `firewall_public_ip_addresses` previously returned only the first module-managed IP address. It now returns all module-managed IP addresses. This is an observable change for consumers that parsed this output, but is a correction of incorrect behavior.
- **Bug fix:** The `total_ips` calculation had a latent bug where the fallthrough case computed `pow(2, 32 - 0) = 4294967296` when `firewall_public_ip_prefix_length` was left at the default of `0`. This could never succeed in practice but is now correctly resolved by the default change to `null` and the restructured ternary logic.

## Files Changed

- `variables.tf` (root)
- `modules/vhub/variables.tf`
- `modules/vhub/local.tf`
- `modules/vhub/main.tf`
- `examples/byoip/main.tf` (new)
- `README.md`
