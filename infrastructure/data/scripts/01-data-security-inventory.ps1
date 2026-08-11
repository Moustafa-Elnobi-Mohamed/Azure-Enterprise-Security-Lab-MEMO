$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== MEMO DATA SECURITY INVENTORY ===" -ForegroundColor Cyan
Write-Host ""

$DataRG = "MEMO-RG-Finance"
$SharedRG = "MEMO-RG-Shared"

Write-Host "Data Resource Group: $DataRG"
Write-Host "Shared Resource Group: $SharedRG"

Write-Host ""
Write-Host "Existing Storage Accounts"
Write-Host "-------------------------"

Get-AzStorageAccount |
Select-Object `
    StorageAccountName,
ResourceGroupName,
Location,
Kind,
SkuName,
EnableHttpsTrafficOnly,
MinimumTlsVersion |
Format-Table -AutoSize

Write-Host ""
Write-Host "=== INVENTORY COMPLETE ===" -ForegroundColor Green