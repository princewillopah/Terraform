
### ---------------------------------------------------
### ADVANCE METHOD 0
### ---------------------------------------------------

# resource "azurerm_resource_group" "rg" {
#   name     = var.resource_group_name
#   location = var.resource_group_location
# }

# resource "azurerm_network_security_group" "security-group" {
#   name                = "sg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_virtual_network" "example" {
#   name                = "p-VNET"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.0.0.0/16"]
#   dns_servers         = ["10.0.0.4", "10.0.0.5"]

#   subnet {
#     name           = "subnet1"
#     address_prefix = "10.0.1.0/24"
#   }

#   subnet {
#     name           = "subnet2"
#     address_prefix = "10.0.2.0/24"
#     security_group = azurerm_network_security_group.security-group.id
#   }

#   tags = {
#     environment = "Production"
#   }
# }

### ---------------------------------------------------
### ADVANCE METHOD 2
### ---------------------------------------------------

# locals {
#   my_resource_group_name = "Prince-RG"
#   my_resource_group_location = "eastus"
#   my_virtual_network = {
#     my_vnet_name = "Prince-VNET"
#     my_vnet_address_space = "10.0.0.0/16"
#     dns-servers = ["10.0.0.4", "10.0.0.5"]
#     subnet_address_prefixes  = ["10.0.1.0/24", "10.0.2.0/24"]
#   }
# }


# resource "azurerm_resource_group" "rg" {
#   name     = local.my_resource_group_name
#   location = local.my_resource_group_location
# }

# resource "azurerm_network_security_group" "security-group" {
#   name                = "sg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_virtual_network" "example" {
#   name                = local.my_virtual_network.my_vnet_name
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = [local.my_virtual_network.my_vnet_address_space]
#   dns_servers         =  local.my_virtual_network.dns-servers  //nor required or compulsory

#   dynamic "subnet" {
#     for_each = local.my_virtual_network.subnet_address_prefixes
#     content {
#       name           = "subnet${subnet.key + 1}"
#       address_prefix = subnet.value
#       // Optionally, you can include other subnet configurations here
#     }
#   }

#   tags = {
#     environment = "${var.env}-Production"
#   }
# }

# ### ---------------------------------------------------
# ### ADVANCE METHOD 3A
# ### ---------------------------------------------------

# locals {
#   my_resource_group_name = "Prince-RG"
#   my_resource_group_location = "eastus"
#   my_virtual_network = {
#     my_vnet_name = "Prince-VNET"
#     my_vnet_address_space = "10.0.0.0/16"
#     dns-servers = ["10.0.0.4", "10.0.0.5"]
#     subnet_info = {
#       name = ["SubnetA","SubnetB"]
#       sub_addr_prefixes  = ["10.0.1.0/24", "10.0.2.0/24"]
#     }
    
#   }
# }


# resource "azurerm_resource_group" "rg" {
#   name     = local.my_resource_group_name
#   location = local.my_resource_group_location
# }

# resource "azurerm_network_security_group" "security-group" {
#   name                = "sg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_virtual_network" "example" {
#   name                = local.my_virtual_network.my_vnet_name
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = [local.my_virtual_network.my_vnet_address_space]
#   dns_servers         =  local.my_virtual_network.dns-servers  //nor required or compulsory

#   subnet {
#     name           = local.my_virtual_network.subnet_info.name[0]
#     address_prefix = local.my_virtual_network.subnet_info.sub_addr_prefixes[0]
#   }

#   subnet {
#     name           = local.my_virtual_network.subnet_info.name[1]
#     address_prefix = local.my_virtual_network.subnet_info.sub_addr_prefixes[1]
#     security_group = azurerm_network_security_group.security-group.id
#   }

#   tags = {
#     environment = "${var.env}-Production"
#   }
# }


### ---------------------------------------------------
### ADVANCE METHOD 3B
### ---------------------------------------------------

# locals {
#   my_resource_group_name = "Prince-RG"
#   my_resource_group_location = "eastus"
#   my_virtual_network = {
#     my_vnet_name = "Prince-VNET"
#     my_vnet_address_space = "10.0.0.0/16"
#     dns-servers = ["10.0.0.4", "10.0.0.5"]
#     subnet_info = {
#       name = ["SubnetA","SubnetB"]
#       sub_addr_prefixes  = ["10.0.1.0/24", "10.0.2.0/24"]
#     }
    
#   }
# }


# resource "azurerm_resource_group" "rg" {
#   name     = local.my_resource_group_name
#   location = local.my_resource_group_location
# }

# resource "azurerm_network_security_group" "security-group" {
#   name                = "sg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_virtual_network" "example" {
#   name                = local.my_virtual_network.my_vnet_name
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = [local.my_virtual_network.my_vnet_address_space]
#   dns_servers         =  local.my_virtual_network.dns-servers  //nor required or compulsory

#  dynamic "subnet" {
#     for_each = local.my_virtual_network.subnet_info.name
#     content {
#       name           = subnet.value
#       address_prefix = local.my_virtual_network.subnet_info.sub_addr_prefixes[subnet.key]
#     }
#   }

#   tags = {
#     environment = "${var.env}-Production"
#   }
# }
# ### ---------------------------------------------------
# ### ADVANCE METHOD 4
# ### ---------------------------------------------------

# locals {
#   my_resource_group_name = "Prince-RG"
#   my_resource_group_location = "eastus"
#   my_virtual_network = {
#     my_vnet_name = "Prince-VNET"
#     my_vnet_address_space = "10.0.0.0/16"
#     dns-servers = ["10.0.0.4", "10.0.0.5"]
#     my_subnets = [
#       {
#         name           = "subnet1"
#         address_prefix = "10.0.1.0/24"
#       },
#       {
#         name           = "subnet2"
#         address_prefix = "10.0.2.0/24"
#         security_group = azurerm_network_security_group.security-group.id
#       },
#     ]
    
#   }
# }


# resource "azurerm_resource_group" "rg" {
#   name     = local.my_resource_group_name
#   location = local.my_resource_group_location
# }

# resource "azurerm_network_security_group" "security-group" {
#   name                = "sg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_virtual_network" "example" {
#   name                = local.my_virtual_network.my_vnet_name
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = [local.my_virtual_network.my_vnet_address_space]
#   dns_servers         =  local.my_virtual_network.dns-servers  //nor required or compulsory

#    dynamic "subnet" {
#     for_each = local.my_virtual_network.my_subnets
#     content {
#       name           = subnet.value.name
#       address_prefix = subnet.value.address_prefix
#       security_group = lookup(subnet.value, "security_group", null) // Since not all subnets might have a security group associated with them, this situation handled  by checking if the security_group attribute is defined for each subnet.
#     }
#   }

#   tags = {
#     environment = "${var.env}-Production"
#   }
# }

### ---------------------------------------------------
### ADVANCE METHOD 5 -- creating the subnents in a different block(outside the vnet)
### ---------------------------------------------------


# locals {
#   my_resource_group_name = "Prince-RG"
#   my_resource_group_location = "eastus"
# }


# resource "azurerm_resource_group" "rg" {
#   name     = local.my_resource_group_name
#   location = local.my_resource_group_location
# }

# resource "azurerm_virtual_network" "vnet" {
#   name                = "p-VNET"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.0.0.0/16"]
#   dns_servers         = ["10.0.0.4", "10.0.0.5"]

#   tags = {
#     environment = "Production"
#   }
# }// end vnet

#   resource "azurerm_subnet" "SubnetA"{
#     name           = "subnet1"
#     resource_group_name = azurerm_resource_group.rg.name
#     virtual_network_name = azurerm_virtual_network.vnet.name
#     address_prefixes = ["10.0.1.0/24"]

#   }

#   resource "azurerm_subnet" "SubnetB"{
#     name           = "subnet2"
#     resource_group_name = azurerm_resource_group.rg.name
#     virtual_network_name = azurerm_virtual_network.vnet.name
#     address_prefixes = ["10.0.2.0/24"]
# }





### ---------------------------------------------------
### ADVANCE METHOD 5b -- creating the subnents in a different block(outside the vnet) -- using count
### ---------------------------------------------------

# locals {
#   my_resource_group_name    = "Prince-RG"
#   my_resource_group_location = "eastus"
  
#   subnets = [
#     {
#       name           = "subnet1"
#       address_prefix = "10.0.1.0/24"
#       security_group = azurerm_network_security_group.security-group.id
#     },
#     {
#       name           = "subnet2"
#       address_prefix = "10.0.2.0/24"
#     }
#   ]
# }

# resource "azurerm_resource_group" "rg" {
#   name     = local.my_resource_group_name
#   location = local.my_resource_group_location
# }

# resource "azurerm_network_security_group" "security-group" {
#   name                = "sg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_virtual_network" "vnet" {
#   name                = "p-VNET"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.0.0.0/16"]
#   dns_servers         = ["10.0.0.4", "10.0.0.5"]

#   tags = {
#     environment = "Production"
#   }
# }

# resource "azurerm_subnet" "subnets" {
#   count               = length(local.subnets)
#   name                = local.subnets[count.index].name
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes    = [local.subnets[count.index].address_prefix]
#   # network_security_group_id = local.subnets[count.index].security_group != null ? local.subnets[count.index].security_group : null
# }

### ---------------------------------------------------
### ADVANCE METHOD 5c -- creating the subnents in a different block(outside the vnet) --using foreach for list of subnets
### ---------------------------------------------------
# locals {
#   my_resource_group_name    = "Prince-RG"
#   my_resource_group_location = "eastus"
  
#   subnets = [
#     {
#       name           = "subnet1"
#       address_prefix = "10.0.1.0/24"
#       security_group = azurerm_network_security_group.security-group.id
#     },
#     {
#       name           = "subnet2"
#       address_prefix = "10.0.2.0/24"
#     }
#   ]
# }

# resource "azurerm_resource_group" "rg" {
#   name     = local.my_resource_group_name
#   location = local.my_resource_group_location
# }

# resource "azurerm_network_security_group" "security-group" {
#   name                = "sg"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_virtual_network" "vnet" {
#   name                = "p-VNET"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space       = ["10.0.0.0/16"]
#   dns_servers         = ["10.0.0.4", "10.0.0.5"]

#   tags = {
#     environment = "Production"
#   }
# }

# resource "azurerm_subnet" "subnets" {
#   for_each               = { for idx, subnet in local.subnets : idx => subnet }
#   name                = each.value.name
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes    = [each.value.address_prefix]
#   # network_security_group_id = local.subnets[count.index].security_group != null ? local.subnets[count.index].security_group : null
# }



### ---------------------------------------------------
### ADVANCE METHOD 5c -- creating the subnents in a different block(outside the vnet) --using foreach for map of subnets
### ---------------------------------------------------
locals {
  my_resource_group_name    = "Prince-RG"
  my_resource_group_location = "eastus"
  
  subnets = {
    subnet1 = {
      name           = "subnet1"
      address_prefix = "10.0.1.0/24"
      security_group = azurerm_network_security_group.security-group.id
    },
    subnet2 =  {
      name           = "subnet2"
      address_prefix = "10.0.2.0/24"
    }
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

resource "azurerm_virtual_network" "vnet" {
  name                = "p-VNET"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "subnets" {
  for_each            = local.subnets
  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = [each.value.address_prefix]
  # network_security_group_id = local.subnets[count.index].security_group != null ? local.subnets[count.index].security_group : null
}

# resource "azurerm_subnet" "subnets" {
#   for_each            = toset(["data1","data2","data3"])
#   name                = each.key
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes    = [each.value.address_prefix]
#   # network_security_group_id = local.subnets[count.index].security_group != null ? local.subnets[count.index].security_group : null
# }