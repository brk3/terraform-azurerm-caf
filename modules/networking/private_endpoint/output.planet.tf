# This file contains outputs related to features added by Planet that are either not ready for
# upstream or not applicable.

output "private_ip_address" {
  value = azurerm_private_endpoint.pep.private_service_connection[0].private_ip_address
}
