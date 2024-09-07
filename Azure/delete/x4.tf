resource "azurerm_application_gateway" "app_gateway" {
  name                 = "my-app-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                  = "Standard_v2"

  frontend_port        = 80
  frontend_ip_configuration {
    name               = "frontend"
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  backend_http_settings {
    name               = "backend_http_settings"
    port               = 80
    protocol           = "Http"
    cookie_based_affinity = "Disabled"
    connection_timeout = 30
    idle_timeout       = 30
    request_timeout    = 30
    capacity           = 50
    health_probe {
      protocol            = "HTTP"
      port                = 80
      path                = "/healthcheck"
      interval            = 30
      healthy_threshold    = 2
      unhealthy_threshold = 2
    }
  }

  http_listener {
    name               = "http_listener"
    frontend_ip_configuration_name = azurerm_application_gateway.app_gateway.frontend_ip_configuration.name
    frontend_port       = 80
    protocol           = "Http"
    rule               = azurerm_application_gateway_http_listener_rule.rule.name
  }

  http_listener_rule {
    name               = "rule"
    http_listener_name = azurerm_application_gateway.app_gateway.http_listener.name
    backend_pool_name   = azurerm_application_gateway.app_gateway.backend_http_settings.name
  }
}

resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "app-gateway-public-ip"
  resource_group_name = azurerm_resource_group.rg.name   

  allocation_method   = "Static"
}
