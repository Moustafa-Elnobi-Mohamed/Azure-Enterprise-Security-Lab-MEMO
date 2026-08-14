data "azurerm_client_config" "current" {}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {}
}

module "networking" {
  source = "../../modules/networking"

  resource_group_name = "MEMO-RG-Network"
  location            = "eastus"
  vnet_name           = "MEMO-VNET-CORE"
  address_space       = "10.10.0.0/16"

  tags = {
    Project     = "MEMO"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Security    = "SC-500"
  }
}
module "keyvault" {
  source = "../../modules/keyvault"

  resource_group_name = "MEMO-RG-Security"
  location            = "eastus"
  key_vault_name      = "MEMO-KV-SECURITY"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  tags = {
    Project     = "MEMO"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Security    = "SC-500"
  }
}
module "storage" {
  source = "../../modules/storage"

  resource_group_name  = "MEMO-RG-Shared"
  location             = "eastus"
  storage_account_name = "memosecdata48219"

  tags = {
    Project     = "MEMO"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Security    = "SC-500"
  }
}

module "storage_private_endpoint" {
  source = "../../modules/private-endpoint"

  name                = "MEMO-PE-STORAGE"
  resource_group_name = "MEMO-RG-Network"
  location            = "eastus"

  subnet_id = module.networking.data_subnet_id

  private_connection_resource_id = module.storage.storage_account_id
  subresource_names              = ["blob"]

  private_dns_zone_ids = [
    module.storage_private_dns.private_dns_zone_id
  ]

  tags = {
    Project     = "MEMO"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Security    = "SC-500"
  }
}

module "storage_private_dns" {
  source = "../../modules/private-dns"

  resource_group_name   = "MEMO-RG-Network"
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  virtual_network_id    = module.networking.vnet_id
  vnet_link_name        = "MEMO-LINK-STORAGE-BLOB"

  tags = {
    Project     = "MEMO"
    Environment = "Lab"
    ManagedBy   = "Terraform"
    Security    = "SC-500"
  }
}

