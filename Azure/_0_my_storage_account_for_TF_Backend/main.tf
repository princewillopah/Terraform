# terraform {
#   required_providers {
#     azurerm = {
#       source = "hashicorp/azurerm"
#       version = "4.29.0"
#     }
#   }
#     backend "azurerm" {
#         resource_group_name  = azurerm_resource_group.state_rg.name
#         storage_account_name = azurerm_storage_account.state_sa.name
#         container_name       = azurerm_storage_container.state_container.name
#         key                 = "terraform.tfstate"
#     }

#   required_version = ">= 1.0.0"
# }

# provider "azurerm" { 
#   features {}
# }


# resource "azurerm_resource_group" "state_rg" {
#   name     = "terraform-state-rg"
#   location = "East US"
# }

# resource "azurerm_storage_account" "state_sa" {
#   name                     = "tfstatestorageaccount"
#   resource_group_name      = azurerm_resource_group.state_rg.name
#   location                 = azurerm_resource_group.state_rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_storage_container" "state_container" {
#   name                  = "tfstate"
#   storage_account_id  = azurerm_storage_account.state_sa.id
#   container_access_type = "private"
# }