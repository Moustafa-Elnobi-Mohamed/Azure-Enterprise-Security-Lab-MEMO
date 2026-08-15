output "vm_id" {
  description = "Secure VM resource ID"
  value       = azurerm_linux_virtual_machine.memo.id
}

output "vm_name" {
  description = "Secure VM name"
  value       = azurerm_linux_virtual_machine.memo.name
}

output "private_ip_address" {
  description = "VM private IP address"
  value       = azurerm_network_interface.memo.private_ip_address
}

output "principal_id" {
  description = "System-assigned managed identity principal ID"
  value       = azurerm_linux_virtual_machine.memo.identity[0].principal_id
}