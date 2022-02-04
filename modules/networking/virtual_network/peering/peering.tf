resource "azurecaf_name" "peering" {
  name          = var.name
  resource_type = "azurerm_virtual_network_peering"
  prefixes      = var.global_settings.prefixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough
  use_slug      = var.global_settings.use_slug
}

resource "azurerm_virtual_network_peering" "peering" {
  name                         = azurecaf_name.peering.result
  virtual_network_name         = var.virtual_network_name
  resource_group_name          = var.resource_group_name
  remote_virtual_network_id    = var.remote_virtual_network_id
  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = var.use_remote_gateways

  lifecycle {
    ignore_changes = [
      remote_virtual_network_id,
      resource_group_name,
      virtual_network_name
    ]
  }
}
