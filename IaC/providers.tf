terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "azure-subscription-id"
}