variable "identity_name" {
  description = "Name of the user-assigned managed identity"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group where the managed identity will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region for the managed identity"
  type        = string
}

variable "tags" {
  description = "Tags applied to the managed identity"
  type        = map(string)
  default     = {}
}