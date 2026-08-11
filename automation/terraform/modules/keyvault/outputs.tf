output "key_vault_id" {
  value = azurerm_key_vault.memo.id
}

output "key_vault_name" {
  value = azurerm_key_vault.memo.name
}

output "key_vault_uri" {
  value = azurerm_key_vault.memo.vault_uri
}