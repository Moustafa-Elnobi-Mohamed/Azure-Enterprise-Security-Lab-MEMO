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