
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
  count             = var.number_subnets
  name              = count.index % 2 == 0 ? "Public-Subnet-${count.index + 2}" : "Private-Subnet-${count.index + 2}"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.my-vnet.name
  address_prefixes  = count.index % 2 == 0 ?  ["10.0.${count.index * 2}.0/24"] :  ["10.0.${(count.index * 2) + 1}.0/24"]
}
// count is going to run even number times. if  var.number_subnets = 6, the count will start running 6 times with each turn as 0, 1, 2, 3, 4, 5
// to interpret: count.index % 2 == 0 ? "Public-Subnet-${count.index + 1}" : "Private-Subnet-${count.index + 1}"
# at count.index = 0: 
        // count.index % 2 == 0 is yes. name = Public-Subnet-${count.index + 2} = Public-Subnet-2
        //count.index % 2 == 0 is yes. address_prefixes =  ["10.0.${count.index * 2}.0/24"]  =  ["10.0.2.0/24"] 

# at count.index = 1: 
        // count.index % 2 == 0 is yes. name = Private-Subnet-${count.index + 2} = Public-Subnet-3
        //count.index % 2 == 0 is yes. address_prefixes =  ["10.0.${(count.index * 2)+1}.0/24"]  =  ["10.0.3.0/24"] 

# and so on



# to run plan: terraform plan -var-file=subnets.tfvars
# to run apply: terraform apply -var-file=subnets.tfvars