terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.29.0"
    }
  }
    backend "azurerm" {
        resource_group_name  = "TF-State-RG"
        storage_account_name = "myterraformstate21834"
        container_name       = "tfstate"
        key                 = "terraform.tfstate"
    }

  required_version = ">= 1.0.0"
}

provider "azurerm" { 
  features {}
}
