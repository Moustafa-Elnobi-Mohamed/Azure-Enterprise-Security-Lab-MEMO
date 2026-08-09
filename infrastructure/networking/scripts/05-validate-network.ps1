# ============================================================
# MEMO Enterprise Security Lab
# Day 6 - Network Validation
# ============================================================

$NetworkRG = "MEMO-RG-Network"

Write-Host ""
Write-Host "=== MEMO NETWORK VALIDATION ===" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------
# VNET
# ------------------------------------------------------------

$vnet = Get-AzVirtualNetwork `
    -Name "MEMO-VNET-CORE" `
    -ResourceGroupName $NetworkRG

Write-Host "VNET:" -ForegroundColor Yellow
Write-Host $vnet.Name
Write-Host "Address Space: $($vnet.AddressSpace.AddressPrefixes -join ', ')"

Write-Host ""
Write-Host "SUBNETS:" -ForegroundColor Yellow

$vnet.Subnets |
Select-Object Name, AddressPrefix |
Format-Table -AutoSize

# ------------------------------------------------------------
# NSGs
# ------------------------------------------------------------

Write-Host ""
Write-Host "NSGs:" -ForegroundColor Yellow

$NSGs = @(
    "MEMO-NSG-APP",
    "MEMO-NSG-DATA",
    "MEMO-NSG-MGMT",
    "MEMO-NSG-SECURITY"
)

foreach ($NSGName in $NSGs) {

    $nsg = Get-AzNetworkSecurityGroup `
        -Name $NSGName `
        -ResourceGroupName $NetworkRG

    Write-Host ""
    Write-Host "[$NSGName]" -ForegroundColor Cyan

    $nsg.SecurityRules |
    Select-Object Name, Priority, Direction, Access, Protocol,
    SourceAddressPrefix, DestinationPortRange |
    Format-Table -AutoSize
}

# ------------------------------------------------------------
# SUBNET -> NSG ASSOCIATIONS
# ------------------------------------------------------------

Write-Host ""
Write-Host "SUBNET / NSG ASSOCIATIONS:" -ForegroundColor Yellow

$vnet.Subnets |
Select-Object Name,
AddressPrefix,
@{Name = "NSG"; Expression = {
        if ($_.NetworkSecurityGroup) {
            $_.NetworkSecurityGroup.Id.Split("/")[-1]
        }
        else {
            "NONE"
        }
    }
} |
Format-Table -AutoSize

Write-Host ""
Write-Host "=== NETWORK VALIDATION COMPLETE ===" -ForegroundColor Green