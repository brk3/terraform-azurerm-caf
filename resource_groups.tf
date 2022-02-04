
module "resource_groups" {
  source = "./modules/resource_group"
  for_each = {
    for key, value in try(var.resource_groups, {}) : key => value
    if try(value.reuse, false) == false && try(value.provision_in_hub, false) == false
  }

  resource_group_name = each.value.name
  settings            = each.value
  global_settings     = local.global_settings
  tags                = var.tags
}


module "resource_group_reused" {
  depends_on = [module.resource_groups]
  source     = "./modules/resource_group_reused"
  for_each = {
    for key, value in try(var.resource_groups, {}) : key => value
    if try(value.reuse, false) == true
  }

  settings = each.value
}

module "resource_groups_hub" {
  source = "./modules/resource_group"
  for_each = {
    for key, value in try(var.resource_groups, {}) : key => value
    if try(value.reuse, false) == false && try(value.provision_in_hub, null) == true
  }

  resource_group_name = each.value.name
  settings            = each.value
  global_settings     = local.global_settings
  tags                = var.tags
  providers = {
    azurerm = azurerm.network_hub
  }
}

locals {
  resource_groups = merge(module.resource_groups, module.resource_group_reused, module.resource_groups_hub)
}

output "resource_groups" {
  value = local.resource_groups
}
