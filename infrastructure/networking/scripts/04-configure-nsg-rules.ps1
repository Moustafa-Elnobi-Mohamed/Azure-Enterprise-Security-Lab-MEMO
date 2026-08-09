# ============================================================
# MEMO Enterprise Security Lab
# Day 6 - Network Security Group Configuration
# Cost: $0
# ============================================================

$NetworkRG = "MEMO-RG-Network"

Write-Host ""
Write-Host "=== MEMO NSG Security Configuration ===" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# APP NSG
# ------------------------------------------------------------

$AppNSG = Get-AzNetworkSecurityGroup `
    -Name "MEMO-NSG-APP" `
    -ResourceGroupName $NetworkRG

# Allow HTTPS from Security subnet
$AppNSG | Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-HTTPS-From-Security" `
    -Description "Allow HTTPS traffic from the security subnet" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 101 `
    -SourceAddressPrefix "10.10.4.0/24" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange 443

# Allow internal application traffic
$AppNSG | Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-App-Internal" `
    -Description "Allow internal VNet traffic to application tier" `
    -Access Allow `
    -Protocol "*" `
    -Direction Inbound `
    -Priority 114 `
    -SourceAddressPrefix "10.10.0.0/16" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange "*"

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $AppNSG | Out-Null

Write-Host "APP NSG configured." -ForegroundColor Green


# ------------------------------------------------------------
# DATA NSG
# ------------------------------------------------------------

$DataNSG = Get-AzNetworkSecurityGroup `
    -Name "MEMO-NSG-DATA" `
    -ResourceGroupName $NetworkRG

# Allow SQL traffic only from APP subnet
$DataNSG | Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-SQL-From-App" `
    -Description "Allow database traffic only from application subnet" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 102 `
    -SourceAddressPrefix "10.10.1.0/24" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange 1433

# Allow internal VNet traffic
$DataNSG | Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-Internal-Data" `
    -Description "Allow required internal VNet traffic" `
    -Access Allow `
    -Protocol "*" `
    -Direction Inbound `
    -Priority 111 `
    -SourceAddressPrefix "10.10.0.0/16" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange "*"

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $DataNSG | Out-Null

Write-Host "DATA NSG configured." -ForegroundColor Green


# ------------------------------------------------------------
# MGMT NSG
# ------------------------------------------------------------

$MgmtNSG = Get-AzNetworkSecurityGroup `
    -Name "MEMO-NSG-MGMT" `
    -ResourceGroupName $NetworkRG

# Allow RDP only from Security subnet
$MgmtNSG | Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-RDP-From-Security" `
    -Description "Allow RDP management access only from security subnet" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 115 `
    -SourceAddressPrefix "10.10.4.0/24" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange 3389

# Allow SSH only from Security subnet
$MgmtNSG | Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-SSH-From-Security" `
    -Description "Allow SSH management access only from security subnet" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix "10.10.4.0/24" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange 22

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $MgmtNSG | Out-Null

Write-Host "MGMT NSG configured." -ForegroundColor Green


# ------------------------------------------------------------
# SECURITY NSG
# ------------------------------------------------------------

$SecurityNSG = Get-AzNetworkSecurityGroup `
    -Name "MEMO-NSG-SECURITY" `
    -ResourceGroupName $NetworkRG

# Allow internal security traffic
$SecurityNSG | Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-Security-Internal" `
    -Description "Allow internal VNet traffic to security subnet" `
    -Access Allow `
    -Protocol "*" `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix "10.10.0.0/16" `
    -SourcePortRange "*" `
    -DestinationAddressPrefix "*" `
    -DestinationPortRange "*"

Set-AzNetworkSecurityGroup -NetworkSecurityGroup $SecurityNSG | Out-Null

Write-Host "SECURITY NSG configured." -ForegroundColor Green

Write-Host ""
Write-Host "=== NSG configuration complete ===" -ForegroundColor Cyan