resource "azurerm_virtual_network" "memo" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]

  tags = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "app" {
  name                 = "MEMO-SUBNET-APP"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.memo.name
  address_prefixes     = ["10.10.1.0/24"]

  default_outbound_access_enabled = false

}

resource "azurerm_subnet" "data" {
  name                 = "MEMO-SUBNET-DATA"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.memo.name
  address_prefixes     = ["10.10.2.0/24"]

  default_outbound_access_enabled = false

}

resource "azurerm_subnet" "mgmt" {
  name                 = "MEMO-SUBNET-MGMT"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.memo.name
  address_prefixes     = ["10.10.3.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "security" {
  name                 = "MEMO-SUBNET-SECURITY"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.memo.name
  address_prefixes     = ["10.10.4.0/24"]
  default_outbound_access_enabled = false
}