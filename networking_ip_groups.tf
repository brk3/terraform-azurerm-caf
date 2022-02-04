locals {
  ip_groups_modules = merge(module.ip_groups, module.ip_groups_hub)
}

module "ip_groups" {
  source   = "./modules/networking/ip_group"
  for_each = {
    for key, value in local.networking.ip_groups : key => value
    if try(value.provision_in_hub, false) == false
  }

  global_settings = local.global_settings
  client_config   = local.client_config
  name            = each.value.name
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  tags            = try(each.value.tags, null)
  vnet            = lookup(each.value, "cidrs", null) != null ? null : lookup(each.value, "lz_key", null) == null ? local.combined_objects_networking[local.client_config.landingzone_key][each.value.vnet_key] : local.combined_objects_networking[each.value.lz_key][each.value.vnet_key]
  settings        = each.value
  base_tags       = try(local.global_settings.inherit_tags, false) ? local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags : {}
}

module "ip_groups_hub" {
  source   = "./modules/networking/ip_group"
  for_each = {
    for key, value in local.networking.ip_groups : key => value
    if try(value.provision_in_hub, null) == true
  }

  global_settings = local.global_settings
  client_config   = local.client_config
  name            = each.value.name
  resource_group  = local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)]
  tags            = try(each.value.tags, null)
  vnet            = lookup(each.value, "cidrs", null) != null ? null : lookup(each.value, "lz_key", null) == null ? local.combined_objects_networking[local.client_config.landingzone_key][each.value.vnet_key] : local.combined_objects_networking[each.value.lz_key][each.value.vnet_key]
  settings        = each.value
  base_tags       = try(local.global_settings.inherit_tags, false) ? local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags : {}

  providers = {
    azurerm = azurerm.network_hub
  }
}

output "ip_groups" {
  value = local.ip_groups_modules
}
