resource "azurerm_application_gateway" "app_gateway" {
  name                = "web-app-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  frontend_ip_configuration {
    name = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.app_gateway_public_ip.id
  }

  backend_address_pool {
    name = "backend-pool"
    backend_addresses {
      fqdn = "web-vm-1.eastus.cloudapp.azure.com" # Replace with actual FQDNs or IPs
    }
    backend_addresses {
      fqdn = "web-vm-2.eastus.cloudapp.azure.com" # Replace with actual FQDNs or IPs
    }
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_id  = azurerm_application_gateway.frontend_ip_configuration[0].id
    frontend_port_id               = azurerm_application_gateway.frontend_port[0].id
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                 = "Basic"
    http_listener_id          = azurerm_application_gateway.http_listener[0].id
    backend_address_pool_id   = azurerm_application_gateway.backend_address_pool[0].id
  }
}

resource "azurerm_public_ip" "app_gateway_public_ip" {
  name                = "app-gateway-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

