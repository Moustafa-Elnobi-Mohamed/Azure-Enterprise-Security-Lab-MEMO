output "identity_id" {
  description = "Resource ID of the managed identity"
  value       = azurerm_user_assigned_identity.memo.id
}

output "principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.memo.principal_id
}

output "client_id" {
  description = "Client ID of the managed identity"
  value       = azurerm_user_assigned_identity.memo.client_id
}

output "identity_name" {
  description = "Name of the managed identity"
  value       = azurerm_user_assigned_identity.memo.name
}