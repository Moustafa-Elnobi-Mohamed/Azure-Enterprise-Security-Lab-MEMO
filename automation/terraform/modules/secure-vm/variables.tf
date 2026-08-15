variable "vm_name" {
  description = "Name of the secure MEMO virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the VM"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "Subnet used by the VM"
  type        = string
}

variable "admin_username" {
  description = "Administrator username"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}