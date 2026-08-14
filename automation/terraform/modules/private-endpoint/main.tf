resource "azurerm_private_endpoint" "memo" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = false
    subresource_names              = var.subresource_names
  }

  tags = var.tags
  private_dns_zone_group {
    name                 = "MEMO-Storage-DNS-Group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

}
