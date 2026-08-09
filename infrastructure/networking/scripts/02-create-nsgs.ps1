# ============================================================
# MEMO Foundation
# Azure Enterprise Security Lab
# Network Security Groups
# ============================================================

$ErrorActionPreference = "Stop"

# -----------------------------
# Configuration
# -----------------------------

$NetworkRG = "MEMO-RG-Network"
$Location = "East US"

$NSGs = @(
    "MEMO-NSG-APP",
    "MEMO-NSG-DATA",
    "MEMO-NSG-MGMT",
    "MEMO-NSG-SECURITY"
)

# -----------------------------
# Ensure Resource Group exists
# -----------------------------

$rg = Get-AzResourceGroup `
    -Name $NetworkRG `
    -ErrorAction SilentlyContinue

if (-not $rg) {

    Write-Host "Creating resource group: $NetworkRG"

    New-AzResourceGroup `
        -Name $NetworkRG `
        -Location $Location | Out-Null
}

# -----------------------------
# Create NSGs
# -----------------------------

foreach ($NSGName in $NSGs) {

    $existingNSG = Get-AzNetworkSecurityGroup `
        -Name $NSGName `
        -ResourceGroupName $NetworkRG `
        -ErrorAction SilentlyContinue

    if (-not $existingNSG) {

        Write-Host "Creating NSG: $NSGName"

        New-AzNetworkSecurityGroup `
            -Name $NSGName `
            -ResourceGroupName $NetworkRG `
            -Location $Location | Out-Null

    } else {

        Write-Host "NSG already exists: $NSGName"
    }
}

# -----------------------------
# Verification
# -----------------------------

Write-Host ""
Write-Host "============================================"
Write-Host "MEMO NSGs configured."
Write-Host "============================================"

Get-AzNetworkSecurityGroup `
    -ResourceGroupName $NetworkRG |
    Select-Object Name, Location, ResourceGroupName