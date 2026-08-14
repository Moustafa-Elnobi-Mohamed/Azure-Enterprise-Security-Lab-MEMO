resource "azurerm_private_dns_zone" "memo" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "memo" {
  name                  = var.vnet_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.memo.name
  virtual_network_id    = var.virtual_network_id

  registration_enabled = false
}