provider "azurerm" {
  partner_id = "ca4078f8-9bc4-471b-ab5b-3af6b86a42c8"
  # partner identifier for CAF Terraform landing zones.
  features {
    template_deployment {
      delete_nested_items_during_deletion = false
    }
  }

  subscription_id = local.global_settings.hub_subscription_id
  alias           = "network_hub"
}
