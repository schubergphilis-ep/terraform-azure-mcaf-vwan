# Changelog

All notable changes to this project will automatically be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.4.0 - 2026-04-16

### What's Changed

#### 🚀 Features

* feature: add `firewall_public_ip_tags` variable to the vhub module, allowing additional tags to be assigned specifically to the public IP resources created for the Azure Firewall. This is a non-breaking addition — the variable defaults to an empty map, so existing configurations require no changes.

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v1.3.0...v1.4.0

## v1.3.0 - 2026-03-20

### What's Changed

Possible Breaking change (although small chance): stricter validation requires explicit IP source when not using classic mode. Most deployments unaffected."
Basic, you have to select an ip_mode which probably already have..
option 1: firewall_classic_ip_config = true  # ← Azure manages IPs
option 2:  firewall_public_ip_count = 1  # ← Explicitly set how many IPs
option 3: firewall_public_ip_prefix_length = 30  # ← Create IPs from prefix
option 4: (none of the above) but -> firewall_custom_ip_configurations =       {
name                 = "custom-ip-1"
public_ip_address_id = azurerm_public_ip.example.id
}

#### 🚀 Features

* feature: adding byoip only support to the module, so you can remove included prefixes (#19) @Blankf

#### 🐛 Bug Fixes

* feature: adding byoip only support to the module, so you can remove included prefixes (#19) @Blankf

#### 📖 Documentation

* feature: adding byoip only support to the module, so you can remove included prefixes (#19) @Blankf

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v1.2.0...v1.3.0

## v1.2.0 - 2026-01-21

### What's Changed

#### 🚀 Features

* feature: add optional insights block to firewall policy (#18) @Blankf

#### 📖 Documentation

* feature: add optional insights block to firewall policy (#18) @Blankf

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v1.1.0...v1.2.0

## v1.1.0 - 2026-01-21

### What's Changed

#### 🚀 Features

* enhancement: Make firewall variables and routing intent optional when not used. (#17) @stimmerman

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v1.0.1...v1.1.0

## v1.0.1 - 2025-05-13

### What's Changed

#### 🐛 Bug Fixes

* bug: Fix zones prefix (#16) @Blankf

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v1.0.0...v1.0.1

## v1.0.0 - 2025-05-12

### What's Changed

#### 🚀 Features

* enhancement: new virtual wan firewall options (#15) @Blankf

#### 📖 Documentation

* enhancement: new virtual wan firewall options (#15) @Blankf

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v0.8.3...v1.0.0

## v0.8.3 - 2025-04-02

### What's Changed

#### 🐛 Bug Fixes

* fix: output error (#14) @gillianstravers

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v0.8.2...v0.8.3

## v0.8.2 - 2025-04-02

### What's Changed

#### 🐛 Bug Fixes

* bug: RG creation (#13) @gillianstravers

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v0.8.1...v0.8.2

## v0.8.1 - 2025-03-31

### What's Changed

#### 🧺 Miscellaneous

* chore: minor code improvements (#12) @niekvanraaij

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v0.8.0...v0.8.1

## v0.8.0 - 2025-03-11

### What's Changed

#### 🚀 Features

* enhancement: module outputs (#11) @Blankf

**Full Changelog**: https://github.com/schubergphilis/terraform-azure-mcaf-vwan/compare/v0.7.1...v0.8.0
