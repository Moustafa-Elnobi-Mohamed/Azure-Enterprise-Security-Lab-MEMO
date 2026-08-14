variable "resource_group_name" {
  description = "Resource group for the private DNS zone"
  type        = string
}

variable "private_dns_zone_name" {
  description = "Private DNS zone name"
  type        = string
}

variable "virtual_network_id" {
  description = "Virtual network ID to link to the private DNS zone"
  type        = string
}

variable "vnet_link_name" {
  description = "Name of the private DNS VNet link"
  type        = string
}

variable "tags" {
  description = "Tags for the private DNS resources"
  type        = map(string)
  default     = {}
}