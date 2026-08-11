output "vnet_id" {
  value = azurerm_virtual_network.memo.id
}

output "vnet_name" {
  value = azurerm_virtual_network.memo.name
}

output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "data_subnet_id" {
  value = azurerm_subnet.data.id
}

output "mgmt_subnet_id" {
  value = azurerm_subnet.mgmt.id
}

output "security_subnet_id" {
  value = azurerm_subnet.security.id
}