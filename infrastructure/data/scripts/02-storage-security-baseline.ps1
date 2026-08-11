$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=== MEMO STORAGE SECURITY BASELINE ===" -ForegroundColor Cyan
Write-Host ""

$StorageAccounts = Get-AzStorageAccount

if (-not $StorageAccounts) {
    Write-Host "No storage accounts currently exist." -ForegroundColor Yellow
    Write-Host "Baseline documented without creating billable resources."
    exit
}

foreach ($Storage in $StorageAccounts) {

    Write-Host ""
    Write-Host "Storage Account: $($Storage.StorageAccountName)" -ForegroundColor Cyan
    Write-Host "Resource Group:  $($Storage.ResourceGroupName)"
    Write-Host "Location:        $($Storage.Location)"
    Write-Host "SKU:             $($Storage.SkuName)"
    Write-Host "HTTPS Only:      $($Storage.EnableHttpsTrafficOnly)"
    Write-Host "TLS Version:     $($Storage.MinimumTlsVersion)"
}