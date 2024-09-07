resource "azurerm_sql_server" "example" {
  name                         = "example-sql-server"
  resource_group_name          = azurerm_resource_group.RG.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "password123!"
}

resource "azurerm_sql_database" "example" {
  name                = "example-sql-database"
  resource_group_name = azurerm_resource_group.RG.name
  location            = var.location
  server_name         = azurerm_sql_server.example.name

  sku_name = "S0"

  tags = {
    environment = "production"
  }
}

# Azure SQL Server
resource "azurerm_sql_server" "sql_server" {
  name                         = "${random_pet.rg_name.id}-sql-server"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_admin_password
}

# Azure SQL Database
resource "azurerm_sql_database" "sql_db" {
  name                        = "${random_pet.rg_name.id}-sql-db"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  server_name                 = azurerm_sql_server.sql_server.name
  edition                     = "Standard"
  requested_service_objective_name = "S0"
}