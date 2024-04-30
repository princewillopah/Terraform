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
  subscription_id = "cd9c1eda-b6fd-44cc-bd24-89355a306e5e"
  tenant_id = "10850ea3-42f6-4736-af16-0be4700bf4e2"
  client_id = "c4ade26f-c332-4900-9c3b-a9fe3e652d7f"
  client_secret = "M_j8Q~3CtUlCgFDifxdWVu8t7gn7SHicEqRk.aHu"
  features {
    
  }
}

