# Shared mock resource defaults for azapi provider.

mock_resource "azapi_resource" {
  defaults = {
    id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/azureFirewalls/test-fw"
    output = {}
  }
}
