resource "azurerm_linux_virtual_machine" "dev_eu_north_ubuntu_vm" {
  name                            = "dev-eu-north-ubuntu2204-vm"
  resource_group_name             = azurerm_resource_group.dev_eu_north_rg.name
  location                        = azurerm_resource_group.dev_eu_north_rg.location
  size                            = "Standard_F2"
  admin_username                  = "rahulwagh"
  #admin_password                  = "G<7€YraRgk_7lnksE}yu37`Fe"
  disable_password_authentication = true
  admin_ssh_key {
    username       = "rahulwagh"
    public_key     = file("/Users/rahulwagh/.ssh/dev-vm-ssh-key-pair.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.dev_eu_north_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface" "dev_eu_north_nic" {
  name                = "dev-eu-north-nic"
  location            = azurerm_resource_group.dev_eu_north_rg.location
  resource_group_name = azurerm_resource_group.dev_eu_north_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev_eu_north_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev_eu_north_static_public_ip.id
  }
  depends_on = [azurerm_network_security_group.dev_eu_north_ssh_nsg, azurerm_public_ip.dev_eu_north_static_public_ip]
}

resource "azurerm_public_ip" "dev_eu_north_static_public_ip" {
  name                = "dev-eu-north-static-public-ip"
  resource_group_name = azurerm_resource_group.dev_eu_north_rg.name
  location            = azurerm_resource_group.dev_eu_north_rg.location
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "dev_eu_north_ssh_nsg" {
  name                = "dev-eu-north-ssh-nsg"
  location            = azurerm_resource_group.dev_eu_north_rg.location
  resource_group_name = azurerm_resource_group.dev_eu_north_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Terraform Demo"
  }
}

#Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "dev_eu_north_nsg_nic_association" {
  network_interface_id      = azurerm_network_interface.dev_eu_north_nic.id
  network_security_group_id = azurerm_network_security_group.dev_eu_north_ssh_nsg.id
  depends_on = [azurerm_network_interface.dev_eu_north_nic]
}