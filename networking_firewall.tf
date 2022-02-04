locals {
  firewall_modules = merge(module.azurerm_firewalls, module.azurerm_firewalls_hub)
}

module "azurerm_firewalls" {
  depends_on = [
    module.azurerm_firewall_policies,
    module.azurerm_firewall_policy_rule_collection_groups
  ]
  source   = "./modules/networking/firewall"
  for_each = {
    for key, value in local.networking.azurerm_firewalls : key => value
    if try(value.provision_in_hub, false) == false
  }

  base_tags           = try(local.global_settings.inherit_tags, false) ? local.resource_groups[each.value.resource_group_key].tags : {}
  client_config       = local.client_config
  diagnostic_profiles = try(each.value.diagnostic_profiles, null)
  diagnostics         = local.combined_diagnostics
  global_settings     = local.global_settings
  location            = lookup(each.value, "region", null) == null ? local.resource_groups[each.value.resource_group_key].location : local.global_settings.regions[each.value.region]
  name                = each.value.name
  public_ip_addresses = try(local.public_ip_addresses_modules, null)
  public_ip_id        = try(local.public_ip_addresses_modules[each.value.public_ip_key].id, null)
  public_ip_keys      = try(each.value.public_ip_keys, null)
  resource_group_name = local.resource_groups[each.value.resource_group_key].name
  settings            = each.value
  subnet_id           = try(local.networking_modules[each.value.vnet_key].subnets["AzureFirewallSubnet"].id, null)
  tags                = try(each.value.tags, null)
  virtual_hubs        = local.combined_objects_virtual_hubs
  virtual_networks    = local.combined_objects_networking
  virtual_wans        = local.combined_objects_virtual_wans

  firewall_policy_id = try(coalesce(
    try(local.combined_objects_azurerm_firewall_policies[each.value.firewall_policy.lz_key][each.value.firewall_policy.key].id, null),
    try(local.combined_objects_azurerm_firewall_policies[local.client_config.landingzone_key][each.value.firewall_policy.key].id, null),
    try(local.combined_objects_azurerm_firewall_policies[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.firewall_policy_key].id, null),
    try(each.value.firewall_policy.id, null)
  ), null)
}

module "azurerm_firewalls_hub" {
  depends_on = [
    module.azurerm_firewall_policies,
    module.azurerm_firewall_policy_rule_collection_groups
  ]
  source   = "./modules/networking/firewall"
  for_each = {
    for key, value in local.networking.azurerm_firewalls : key => value
    if try(value.provision_in_hub, null) == true
  }

  base_tags           = try(local.global_settings.inherit_tags, false) ? local.resource_groups[each.value.resource_group_key].tags : {}
  client_config       = local.client_config
  diagnostic_profiles = try(each.value.diagnostic_profiles, null)
  diagnostics         = local.combined_diagnostics
  global_settings     = local.global_settings
  location            = lookup(each.value, "region", null) == null ? local.resource_groups[each.value.resource_group_key].location : local.global_settings.regions[each.value.region]
  name                = each.value.name
  public_ip_addresses = try(local.public_ip_addresses_modules, null)
  public_ip_id        = try(local.public_ip_addresses_modules[each.value.public_ip_key].id, null)
  public_ip_keys      = try(each.value.public_ip_keys, null)
  resource_group_name = local.resource_groups[each.value.resource_group_key].name
  settings            = each.value
  subnet_id           = try(local.networking_modules[each.value.vnet_key].subnets["AzureFirewallSubnet"].id, null)
  tags                = try(each.value.tags, null)
  virtual_hubs        = local.combined_objects_virtual_hubs
  virtual_networks    = local.combined_objects_networking
  virtual_wans        = local.combined_objects_virtual_wans

  firewall_policy_id = try(coalesce(
    try(local.combined_objects_azurerm_firewall_policies[each.value.firewall_policy.lz_key][each.value.firewall_policy.key].id, null),
    try(local.combined_objects_azurerm_firewall_policies[local.client_config.landingzone_key][each.value.firewall_policy.key].id, null),
    try(local.combined_objects_azurerm_firewall_policies[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.firewall_policy_key].id, null),
    try(each.value.firewall_policy.id, null)
  ), null)

  providers = {
    azurerm = azurerm.network_hub
  }
}

# Firewall rules to apply to the firewall when not using firewall manager.

module "azurerm_firewall_network_rule_collections" {
  source = "./modules/networking/firewall_network_rule_collections"
  for_each = {
    for key, firewall in local.networking.azurerm_firewalls : key => firewall
    if lookup(firewall, "azurerm_firewall_network_rule_collections", null) != null &&
    try(firewall.provision_in_hub, false) == false
  }

  resource_group_name                                 = local.firewall_modules[each.key].resource_group_name
  azure_firewall_name                                 = local.firewall_modules[each.key].name
  rule_collections                                    = each.value.azurerm_firewall_network_rule_collections
  azurerm_firewall_network_rule_collection_definition = local.networking.azurerm_firewall_network_rule_collection_definition
  global_settings                                     = local.global_settings
  ip_groups                                           = try(local.ip_groups_modules, null)
}

module "azurerm_firewall_network_rule_collections_hub" {
  source = "./modules/networking/firewall_network_rule_collections"
  for_each = {
    for key, firewall in local.networking.azurerm_firewalls : key => firewall
    if lookup(firewall, "azurerm_firewall_network_rule_collections", null) != null &&
    try(firewall.provision_in_hub, null) == true
  }

  resource_group_name                                 = local.firewall_modules[each.key].resource_group_name
  azure_firewall_name                                 = local.firewall_modules[each.key].name
  rule_collections                                    = each.value.azurerm_firewall_network_rule_collections
  azurerm_firewall_network_rule_collection_definition = local.networking.azurerm_firewall_network_rule_collection_definition
  global_settings                                     = local.global_settings
  ip_groups                                           = try(local.ip_groups_modules, null)

  providers = {
    azurerm = azurerm.network_hub
  }
}

module "azurerm_firewall_application_rule_collections" {
  source = "./modules/networking/firewall_application_rule_collections"
  for_each = {
    for key, firewall in local.networking.azurerm_firewalls : key => firewall
    if lookup(firewall, "azurerm_firewall_application_rule_collections", null) != null &&
    try(firewall.provision_in_hub, false) == false
  }

  resource_group_name                                     = local.firewall_modules[each.key].resource_group_name
  azure_firewall_name                                     = local.firewall_modules[each.key].name
  rule_collections                                        = each.value.azurerm_firewall_application_rule_collections
  azurerm_firewall_application_rule_collection_definition = local.networking.azurerm_firewall_application_rule_collection_definition
  global_settings                                         = local.global_settings
  ip_groups                                               = try(local.ip_groups_modules, null)
}

module "azurerm_firewall_application_rule_collections_hub" {
  source = "./modules/networking/firewall_application_rule_collections"
  for_each = {
    for key, firewall in local.networking.azurerm_firewalls : key => firewall
    if lookup(firewall, "azurerm_firewall_application_rule_collections", null) != null &&
    try(firewall.provision_in_hub, null) == true
  }

  resource_group_name                                     = local.firewall_modules[each.key].resource_group_name
  azure_firewall_name                                     = local.firewall_modules[each.key].name
  rule_collections                                        = each.value.azurerm_firewall_application_rule_collections
  azurerm_firewall_application_rule_collection_definition = local.networking.azurerm_firewall_application_rule_collection_definition
  global_settings                                         = local.global_settings
  ip_groups                                               = try(local.ip_groups_modules, null)

  providers = {
    azurerm = azurerm.network_hub
  }
}


module "azurerm_firewall_nat_rule_collections" {
  source = "./modules/networking/firewall_nat_rule_collections"
  for_each = {
    for key, firewall in local.networking.azurerm_firewalls : key => firewall
    if lookup(firewall, "azurerm_firewall_nat_rule_collections", null) != null &&
    try(firewall.provision_in_hub, false) == false
  }

  resource_group_name                             = local.firewall_modules[each.key].resource_group_name
  azure_firewall_name                             = local.firewall_modules[each.key].name
  rule_collections                                = each.value.azurerm_firewall_nat_rule_collections
  azurerm_firewall_nat_rule_collection_definition = local.networking.azurerm_firewall_nat_rule_collection_definition
  global_settings                                 = local.global_settings
  ip_groups                                       = try(local.ip_groups_modules, null)
  public_ip_addresses                             = try(local.public_ip_addresses_modules, null)
}

module "azurerm_firewall_nat_rule_collections_hub" {
  source = "./modules/networking/firewall_nat_rule_collections"
  for_each = {
    for key, firewall in local.networking.azurerm_firewalls : key => firewall
    if lookup(firewall, "azurerm_firewall_nat_rule_collections", null) != null &&
    try(firewall.provision_in_hub, null) == true
  }

  resource_group_name                             = local.firewall_modules[each.key].resource_group_name
  azure_firewall_name                             = local.firewall_modules[each.key].name
  rule_collections                                = each.value.azurerm_firewall_nat_rule_collections
  azurerm_firewall_nat_rule_collection_definition = local.networking.azurerm_firewall_nat_rule_collection_definition
  global_settings                                 = local.global_settings
  ip_groups                                       = try(local.ip_groups_modules, null)
  public_ip_addresses                             = try(local.public_ip_addresses_modules, null)

  providers = {
    azurerm = azurerm.network_hub
  }
}

output "azurerm_firewalls" {
  value = local.firewall_modules

}
