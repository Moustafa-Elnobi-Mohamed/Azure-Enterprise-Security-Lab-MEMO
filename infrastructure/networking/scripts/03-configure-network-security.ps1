# ============================================================
# MEMO Foundation
# Azure Enterprise Security Lab
# NSG Security Baseline
# ============================================================

$ErrorActionPreference = "Stop"

# -----------------------------
# Configuration
# -----------------------------

$NetworkRG = "MEMO-RG-Network"

# ============================================================
# APP NSG
# ============================================================

$appNSG = Get-AzNetworkSecurityGroup `
    -Name "MEMO-NSG-APP" `
    -ResourceGroupName $NetworkRG

# Allow HTTPS inbound
if (-not ($appNSG.SecurityRules | Where-Object {
    $_.Name -eq "Allow-HTTPS-Inbound"
})) {

    $appNSG | Add-AzNetworkSecurityRuleConfig `
        -Name "Allow-HTTPS-Inbound" `
        -Description "Allow HTTPS traffic to application tier" `
        -Access Allow `
        -Protocol Tcp `
        -Direction Inbound `
        -Priority 100 `
        -SourceAddressPrefix Internet `
        -SourcePortRange "*" `
        -DestinationAddressPrefix "*" `
        -DestinationPortRange 443 | Out-Null
}

# Allow HTTP for lab demonstration
if (-not ($appNSG.SecurityRules | Where-Object {
    $_.Name -eq "Allow-HTTP-Inbound"
})) {

    $appNSG | Add-AzNetworkSecurityRuleConfig `
        -Name "Allow-HTTP-Inbound" `
        -Description "Allow HTTP traffic to application tier for lab testing" `
        -Access Allow `
        -Protocol Tcp `
        -Direction Inbound `
        -Priority 110 `
        -SourceAddressPrefix Internet `
        -SourcePortRange "*" `
        -DestinationAddressPrefix "*" `
        -DestinationPortRange 80 | Out-Null
}

$appNSG | Set-AzNetworkSecurityGroup | Out-Null


# ============================================================
# DATA NSG
# ============================================================

$dataNSG = Get-AzNetworkSecurityGroup `
    -Name "MEMO-NSG-DATA" `
    -ResourceGroupName $NetworkRG

# Explicitly deny direct Internet access to data tier
if (-not ($dataNSG.SecurityRules | Where-Object {
    $_.Name -eq "Deny-Internet-Inbound"
})) {

    $dataNSG | Add-AzNetworkSecurityRuleConfig `
        -Name "Deny-Internet-Inbound" `
        -Description "Prevent direct Internet access to data tier" `
        -Access Deny `
        -Protocol "*" `
        -Direction Inbound `
        -Priority 100 `
        -SourceAddressPrefix Internet `
        -SourcePortRange "*" `
        -DestinationAddressPrefix "*" `
        -DestinationPortRange "*" | Out-Null
}

$dataNSG | Set-AzNetworkSecurityGroup | Out-Null


# ============================================================
# MGMT NSG
# ============================================================

$mgmtNSG = Get-AzNetworkSecurityGroup `
    -Name "MEMO-NSG-MGMT" `
    -ResourceGroupName $NetworkRG

# Do NOT open SSH/RDP to the Internet.
# Management access will be restricted later when a
# management VM or private access path is introduced.

if (-not ($mgmtNSG.SecurityRules | Where-Object {
    $_.Name -eq "Deny-Internet-Management"
})) {

    $mgmtNSG | Add-AzNetworkSecurityRuleConfig `
        -Name "Deny-Internet-Management" `
        -Description "Prevent direct Internet access to management tier" `
        -Access Deny `
        -Protocol "*" `
        -Direction Inbound `
        -Priority 100 `
        -SourceAddressPrefix Internet `
        -SourcePortRange "*" `
        -DestinationAddressPrefix "*" `
        -DestinationPortRange "*" | Out-Null
}

$mgmtNSG | Set-AzNetworkSecurityGroup | Out-Null


# ============================================================
# SECURITY NSG
# ============================================================

$securityNSG = Get-AzNetworkSecurityGroup `
    -Name "MEMO-NSG-SECURITY" `
    -ResourceGroupName $NetworkRG

# Security tooling subnet should not be directly exposed.
if (-not ($securityNSG.SecurityRules | Where-Object {
    $_.Name -eq "Deny-Internet-Inbound"
})) {

    $securityNSG | Add-AzNetworkSecurityRuleConfig `
        -Name "Deny-Internet-Inbound" `
        -Description "Prevent direct Internet access to security tier" `
        -Access Deny `
        -Protocol "*" `
        -Direction Inbound `
        -Priority 100 `
        -SourceAddressPrefix Internet `
        -SourcePortRange "*" `
        -DestinationAddressPrefix "*" `
        -DestinationPortRange "*" | Out-Null
}

$securityNSG | Set-AzNetworkSecurityGroup | Out-Null


# ============================================================
# Verification
# ============================================================

Write-Host ""
Write-Host "============================================"
Write-Host "MEMO NSG security baseline configured."
Write-Host "============================================"

Get-AzNetworkSecurityGroup `
    -ResourceGroupName $NetworkRG |
    Select-Object Name

Write-Host ""
Write-Host "Security rules:"

Get-AzNetworkSecurityGroup `
    -ResourceGroupName $NetworkRG |
    ForEach-Object {

        Write-Host ""
        Write-Host "NSG: $($_.Name)"

        $_.SecurityRules |
            Select-Object Name, Priority, Direction, Access, Protocol,
                SourceAddressPrefix, DestinationPortRange
    }