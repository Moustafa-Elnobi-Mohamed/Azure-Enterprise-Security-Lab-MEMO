variable "name" {
  description = "Name of the private endpoint"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the private endpoint"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet used by the private endpoint"
  type        = string
}

variable "private_connection_resource_id" {
  description = "Resource ID of the PaaS service"
  type        = string
}

variable "subresource_names" {
  description = "Subresources exposed through Private Link"
  type        = list(string)
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs associated with the private endpoint"
  type        = list(string)
  default     = []
}
