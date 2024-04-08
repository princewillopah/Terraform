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
  subscription_id = "fac75931-76d5-4ae4-b04b-0ca3f225a1cb"
  tenant_id = "d680c36b-f94b-4241-88bd-fd8c1a2ab6f0"
  client_id = "78a61f0d-5521-40b7-8f62-b7f2e1ccb057"
  client_secret = "lLp8Q~us.g5PhgabyCETMbvM3_L57jkskovJUclg"
  features {
    
  }
}