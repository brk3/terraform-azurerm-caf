module "traffic_manager_profile" {
  source   = "./modules/networking/traffic_manager/traffic_manager_profile"
  for_each = local.networking.traffic_manager_profile

  settings            = each.value
  resource_group_name = local.combined_objects_resource_groups[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.resource_group_key].name
  location            = try(local.global_settings.regions[each.value.region], local.combined_objects_resource_groups[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.resource_group_key].location)
  base_tags           = try(local.global_settings.inherit_tags, false) ? local.resource_groups[each.value.resource_group_key].tags : {}
}

output "traffic_manager_profile" {
  value = module.traffic_manager_profile
}

module "traffic_manager_endpoint" {
  depends_on = [module.traffic_manager_profile]
  source   = "./modules/networking/traffic_manager/traffic_manager_endpoint"
  for_each = local.networking.traffic_manager_endpoint

  settings            = each.value
  resource_group_name = local.combined_objects_resource_groups[try(each.value.lz_key, local.client_config.landingzone_key)][each.value.resource_group_key].name
  profile_name        = local.combined_objects_traffic_manager_profile[try(each.value.traffic_manager_profile.lz_key, local.client_config.landingzone_key)][each.value.traffic_manager_profile.key].name
}
output "traffic_manager_endpoint" {
  value = module.traffic_manager_endpoint
}

module "traffic_manager_external_endpoint" {
  depends_on = [module.traffic_manager_profile]
  source   = "./modules/networking/traffic_manager/traffic_manager_external_endpoint"
  for_each = local.networking.traffic_manager_external_endpoint

  settings            = each.value
  profile_id        = local.combined_objects_traffic_manager_profile[try(each.value.traffic_manager_profile.lz_key, local.client_config.landingzone_key)][each.value.traffic_manager_profile.key].id
}
output "traffic_manager_external_endpoint" {
  value = module.traffic_manager_external_endpoint
}



module "traffic_manager_nested_endpoint" {
  depends_on = [module.traffic_manager_profile]
  source   = "./modules/networking/traffic_manager/traffic_manager_nested_endpoint"
  for_each = local.networking.traffic_manager_nested_endpoint
  target_resource_id = local.combined_objects_traffic_manager_profile[try(each.value.traffic_manager_profile.lz_key, local.client_config.landingzone_key)][each.value.traffic_manager_profile.key].id
  profile_id  = local.combined_objects_traffic_manager_profile[try(each.value.traffic_manager_profile.lz_key, local.client_config.landingzone_key)][each.value.traffic_manager_profile.key].id
  settings            = each.value
 
 
}

output "traffic_manager_nested_endpoint" {
  value = module.traffic_manager_nested_endpoint
}

