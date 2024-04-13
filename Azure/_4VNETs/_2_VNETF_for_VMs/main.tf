


### ---------------------------------------------------
### ADVANCE METHOD 5c -- creating the subnents in a different block(outside the vnet) --using foreach for map of subnets
### ---------------------------------------------------
locals {
  my_resource_group_name    = "Prince-RG"
  my_resource_group_location = "eastus"
  
  subnets = {
    subnet1 = {
      name           = "Subnet_A"
      address_prefix = "10.0.1.0/24"
      //security_group = azurerm_network_security_group.network-security-group.id
    },
    subnet2 =  {
      name           = "Subnet_B"
      address_prefix = "10.0.2.0/24"
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = local.my_resource_group_name
  location = local.my_resource_group_location
}


resource "azurerm_virtual_network" "vnet" {
  name                = "p-VNET"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "${var.env}-Production"
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

// for VM we will create  network interface and ips

 /////////////  NIC ///////////////////
resource "azurerm_public_ip" "my-public-ip-addr" {
  name                = "PublicIp1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}
 /////////////  NIC ///////////////////
resource "azurerm_network_interface" "Network-Interface" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets["subnet1"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.my-public-ip-addr.id # to Public IP Address to associate with this NIC
  }
}

////////////// NSG  ////////

resource "azurerm_network_security_group" "network-security-group" {
  name                = "sg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "ssh-rule" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.network-security-group.name
}

resource "azurerm_network_security_rule" "custom-port-range-rule" {
  name                        = "CustomPortRange"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000-5000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.network-security-group.name
}

 /////////////  ASSOCIATE NSG TO SUBNET  ///////////////////

 resource "azurerm_subnet_network_security_group_association" "assoc-nsg-subnet" {
  subnet_id                 = azurerm_subnet.subnets["subnet1"].id
  network_security_group_id = azurerm_network_security_group.network-security-group.id
}

