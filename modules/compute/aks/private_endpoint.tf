
module "private_endpoint" {
  source   = "../../networking/private_endpoint"
  for_each = var.settings.private_endpoints

  resource_id         = azurerm_kubernetes_cluster.aks.id
  name                = try(each.value.name, each.key)
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  subnet_id           = try(var.remote_objects.vnets[var.client_config.landingzone_key][each.value.vnet_key].subnets[each.value.subnet_key].id, var.remote_objects.vnets[each.value.lz_key][each.value.vnet_key].subnets[each.value.subnet_key].id)
  settings            = each.value
  global_settings     = var.global_settings
  base_tags           = local.tags
  private_dns         = var.remote_objects.private_dns
  client_config       = var.client_config
}

resource "azurerm_private_dns_a_record" "a" {
  for_each = var.settings.private_endpoints

  name = local.aks_cluster_a_record
  zone_name           = var.remote_objects.private_dns[try(each.value.private_dns.lz_key, var.client_config.landingzone_key)][each.value.private_dns.zone_key].name
  resource_group_name = var.remote_objects.resource_groups[try(each.value.private_dns.lz_key, var.client_config.landingzone_key)][each.value.private_dns.resource_group_key].name
  ttl                 = try(each.value.ttl, 300)
  records             = [module.private_endpoint[each.key].private_ip_address]
  tags                = merge(var.base_tags, try(each.value.tags, {}))
}

locals {
  aks_cluster_a_record = join(".", slice(split(".", azurerm_kubernetes_cluster.aks.private_fqdn), 0, 2))
}
