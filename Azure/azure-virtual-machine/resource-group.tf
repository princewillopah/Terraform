# Create a resource group
resource "azurerm_resource_group" "dev_eu_north_rg" {
  name     = "dev-eu-north-rg"
  location = "North Europe"
}