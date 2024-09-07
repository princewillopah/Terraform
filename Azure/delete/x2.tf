
# Azure Application Gateway Public IP
resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "${random_pet.rg_name.id}-app-gateway-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Azure Application Gateway
resource "azurerm_application_gateway" "app_gateway" {
  name                = "${random_pet.rg_name.id}-app-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name                  = "app_gateway_ip_configuration"
    subnet_id             = azurerm_subnet.web.id
  }

  frontend_ip_configuration {
    name                 = "frontend_ip_configuration"
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  backend_http_settings {
    name                  = "http_settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  frontend_port {
    name = "frontend_port"
    port = 80
  }

  backend_address_pool {
    name = "backend_pool"
  }

  http_listener {
    name                           = "http_listener"
    frontend_ip_configuration_name = "frontend_ip_configuration"
    frontend_port_name             = "frontend_port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "request_routing_rule"
    rule_type                  = "Basic"
    http_listener_name         = "http_listener"
    backend_address_pool_name  = "backend_pool"
    backend_http_settings_name = "http_settings"
  }
}
