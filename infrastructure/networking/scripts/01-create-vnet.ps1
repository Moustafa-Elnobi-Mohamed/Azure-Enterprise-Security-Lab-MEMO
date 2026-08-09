# ============================================================
# MEMO Foundation
# Azure Enterprise Security Lab
# Network Foundation - VNet and Subnets
# ============================================================

$ErrorActionPreference = "Stop"

# -----------------------------
# Configuration
# -----------------------------

$NetworkRG = "MEMO-RG-Network"
$Location = "East US"
$VNetName = "MEMO-VNET-CORE"

$VNetAddressSpace = "10.10.0.0/16"

$Subnets = @(
    @{
        Name   = "MEMO-SUBNET-APP"
        Prefix = "10.10.1.0/24"
    },
    @{
        Name   = "MEMO-SUBNET-DATA"
        Prefix = "10.10.2.0/24"
    },
    @{
        Name   = "MEMO-SUBNET-MGMT"
        Prefix = "10.10.3.0/24"
    },
    @{
        Name   = "MEMO-SUBNET-SECURITY"
        Prefix = "10.10.4.0/24"
    }
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

} else {

    Write-Host "Resource group already exists: $NetworkRG"
}

# -----------------------------
# Get or create VNet
# -----------------------------

$vnet = Get-AzVirtualNetwork `
    -Name $VNetName `
    -ResourceGroupName $NetworkRG `
    -ErrorAction SilentlyContinue

if (-not $vnet) {

    Write-Host "Creating VNet: $VNetName"

    $vnet = New-AzVirtualNetwork `
        -Name $VNetName `
        -ResourceGroupName $NetworkRG `
        -Location $Location `
        -AddressPrefix $VNetAddressSpace

} else {

    Write-Host "VNet already exists: $VNetName"
}

# -----------------------------
# Ensure subnets exist
# -----------------------------

foreach ($Subnet in $Subnets) {

    $existingSubnet = $vnet.Subnets |
        Where-Object { $_.Name -eq $Subnet.Name }

    if (-not $existingSubnet) {

        Write-Host "Creating subnet: $($Subnet.Name)"

        Add-AzVirtualNetworkSubnetConfig `
            -Name $Subnet.Name `
            -AddressPrefix $Subnet.Prefix `
            -VirtualNetwork $vnet | Out-Null

    } else {

        Write-Host "Subnet already exists: $($Subnet.Name)"
    }
}

# -----------------------------
# Save VNet configuration
# -----------------------------

$vnet | Set-AzVirtualNetwork | Out-Null

Write-Host ""
Write-Host "============================================"
Write-Host "MEMO network foundation configured."
Write-Host "============================================"

# -----------------------------
# Verification
# -----------------------------

Get-AzVirtualNetwork `
    -Name $VNetName `
    -ResourceGroupName $NetworkRG |
    Select-Object Name, ResourceGroupName, Location, AddressSpace

Write-Host ""
Write-Host "Subnets:"

Get-AzVirtualNetwork `
    -Name $VNetName `
    -ResourceGroupName $NetworkRG |
    Select-Object -ExpandProperty Subnets |
    Select-Object Name, AddressPrefix