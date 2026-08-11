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