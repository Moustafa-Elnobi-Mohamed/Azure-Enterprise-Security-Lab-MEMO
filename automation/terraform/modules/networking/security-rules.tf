resource "azurerm_network_security_rule" "app_https" {
  name                        = "Allow-HTTPS-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "MEMO-RG-Network"
  network_security_group_name = "MEMO-NSG-APP"
}

resource "azurerm_network_security_rule" "app_http" {
  name                        = "Allow-HTTP-Inbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "MEMO-RG-Network"
  network_security_group_name = "MEMO-NSG-APP"
}

resource "azurerm_network_security_rule" "data_sql_from_app" {
  name                        = "Allow-SQL-From-App"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "10.10.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = "MEMO-RG-Network"
  network_security_group_name = "MEMO-NSG-DATA"
}

resource "azurerm_network_security_rule" "data_internal" {
  name                        = "Allow-Internal-Data"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "10.10.0.0/16"
  destination_address_prefix  = "*"
  resource_group_name         = "MEMO-RG-Network"
  network_security_group_name = "MEMO-NSG-DATA"
}

resource "azurerm_network_security_rule" "mgmt_rdp" {
  name                        = "Allow-RDP-From-MGMT"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "10.10.3.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = "MEMO-RG-Network"
  network_security_group_name = "MEMO-NSG-MGMT"
}

resource "azurerm_network_security_rule" "mgmt_ssh" {
  name                        = "Allow-SSH-From-MGMT"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "10.10.3.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = "MEMO-RG-Network"
  network_security_group_name = "MEMO-NSG-MGMT"
}

resource "azurerm_network_security_rule" "security_https_internal" {
  name                        = "Allow-HTTPS-Internal"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = "MEMO-RG-Network"
  network_security_group_name = "MEMO-NSG-SECURITY"
}