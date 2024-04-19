
locals {
  my_resource_group_name = "Prince-RG"
  my_resource_group_location = "eastus"
}


resource "azurerm_resource_group" "rg" {
  name     = local.my_resource_group_name
  location = local.my_resource_group_location
}

resource "azurerm_virtual_network" "my-vnet" {
  name                = "p-VNET"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Production"
  }
}// end vnet


resource "azurerm_subnet" "my-subnets" {
  count                   = var.number_public_subnet  // number from variable 
  name                    = "subnet-${count.index + 1}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.my-vnet.name
  address_prefixes          = ["10.0.${count.index}.0/24"]  // ["10.0.0.0/24"],["10.0.0.0/24"],["10.0.3.0/24"],["10.0.3.0/24"]  ...  
 
}

# to run plan: tfap  -var="number_public_subnet=4"
# to run apply: tfa  -var="number_public_subnet=4"