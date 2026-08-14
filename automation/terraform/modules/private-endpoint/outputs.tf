output "id" {
  value = azurerm_private_endpoint.memo.id
}

output "network_interface_id" {
  description = "Resource ID of the network interface"
  value       = azurerm_private_endpoint.memo.network_interface[0].id
}

output "private_ip_address" {
  description = "Private IP address of the private endpoint"
  value       = azurerm_private_endpoint.memo.private_service_connection[0].private_ip_address
}