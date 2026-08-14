output "vnet_id" {

description = "Resource ID of the MEMO virtual network"
  value = azurerm_virtual_network.memo.id
}

output "vnet_name" {
  description = "Name of the MEMO virtual network"
  value = azurerm_virtual_network.memo.name
}

output "app_subnet_id" {
  description = "Resource ID of the application subnet"
  value       = azurerm_subnet.app.id
}

output "data_subnet_id" {
  description = "Resource ID of the data subnet"
  value       = azurerm_subnet.data.id
}

output "mgmt_subnet_id" {
  description = "Resource ID of the management subnet"
  value       = azurerm_subnet.mgmt.id
}

output "security_subnet_id" {
  description = "Resource ID of the security subnet"
  value       = azurerm_subnet.security.id
}