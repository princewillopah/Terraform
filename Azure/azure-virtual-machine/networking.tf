resource "azurerm_virtual_network" "dev_eu_north_vnet" {
  name                = "dev_eu_north_vnet"
  resource_group_name = azurerm_resource_group.dev_eu_north_rg.name
  location            = azurerm_resource_group.dev_eu_north_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "dev_eu_north_public_subnet" {
  name                 = "dev-eu-north-public-subnet"
  resource_group_name  = azurerm_resource_group.dev_eu_north_rg.name
  virtual_network_name = azurerm_virtual_network.dev_eu_north_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_route_table" "dev_eu_north_public_rt" {
  name                = "dev-eu-north-public-rt"
  location            = azurerm_resource_group.dev_eu_north_rg.location
  resource_group_name = azurerm_resource_group.dev_eu_north_rg.name

  route {
    name           = "public_internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "dev_eu_north_public_subent_rt_association" {
  subnet_id      = azurerm_subnet.dev_eu_north_public_subnet.id
  route_table_id = azurerm_route_table.dev_eu_north_public_rt.id
}