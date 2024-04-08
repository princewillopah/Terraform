locals {
  my_resource_group_name = "Prince-RG"
  my_resource_group_location = "eastus"
  my_virtual_network = {
    my_vnet_name = "Prince-VNET"
    my_vnet_address_space = "10.0.0.0/16"
    dns-servers = ["10.0.0.4", "10.0.0.5"]
    subnet_address_prefixes  = ["10.0.1.0/24", "10.0.2.0/24"]
  }
}


resource "azurerm_resource_group" "rg" {
  name     = local.my_resource_group_name
  location = local.my_resource_group_location
}

resource "azurerm_network_security_group" "security-group" {
  name                = "sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "example" {
  name                = local.my_virtual_network.my_vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [local.my_virtual_network.my_vnet_address_space]
  dns_servers         =  local.my_virtual_network.dns-servers  //nor required or compulsory

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.security-group.id
  }

  tags = {
    environment = "Production"
  }
}