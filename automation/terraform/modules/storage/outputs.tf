output "storage_account_id" {
  value = azurerm_storage_account.memo.id
}

output "storage_account_name" {
  value = azurerm_storage_account.memo.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.memo.primary_blob_endpoint
}