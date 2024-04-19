terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.97.1"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = "xxx"
  tenant_id = "xxx"
  client_id = "xxx"
  client_secret = "xxx"
  features {
    
  }
}