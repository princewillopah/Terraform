module "network" {
  source = "./vnet"

  resource_group_name = "demo-rg"
  location            = "East US"

  vnet_name     = "demo-vnet"
  address_space = ["10.0.0.0/16"]

  subnets = {
    public_subnet  = "10.0.1.0/24"
    private_subnet = "10.0.2.0/24"
  }
}
