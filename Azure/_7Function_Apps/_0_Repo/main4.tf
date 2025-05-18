
# Providers & Backend (if needed)
provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "devops-funcapp-rg"
  location = "East US"
}

# Storage Account (required for Function Apps)
resource "azurerm_storage_account" "example" {
  name                     = "funcstoragedemo123"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# App Service Plan (Premium Plan)
resource "azurerm_app_service_plan" "example" {
  name                = "funcapp-premium-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "FunctionApp"
  reserved            = true  # for Linux

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}


# Application Insights
resource "azurerm_application_insights" "example" {
  name                = "funcapp-insights-demo"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

# Function App (Node.js + App Insights + HTTP Trigger) - We’ll assume you have a ZIP file with your Node.js function code and HTTP trigger packed (I’ll note how to make this ZIP below)
resource "azurerm_function_app" "example" {
  name                       = "nodejs-funcapp-demo"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  os_type                    = "linux"
  version                    = "~18" # for Node.js 18 LTS

  site_config {
    application_stack {
      node_version = "18"
    }

    linux_fx_version = "Node|18"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "node"
    WEBSITE_RUN_FROM_PACKAGE = "https://<your-zip-package-url>"  # Replace https://<your-zip-package-url> with the location of your function app ZIP file in blob storage or publicly accessible URL.
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.example.instrumentation_key
  }
}

# ==========================================================================================
# How to Package Your Node.js Function App (HTTP Trigger)
# ==========================================================================================

# Your function app structure should look like:
#     /function-app/
#         ├── HttpTrigger/index.js
#         └── function.json
#         └── host.json
#         └── package.json

# Sample HttpTrigger/index.js:
#     module.exports = async function (context, req) {
#         context.log('HTTP trigger processed a request.');
#         context.res = {
#             status: 200,
#             body: "Hello from Azure Function with Node.js!"
#         };
#     };

# Sample HttpTrigger/function.json:
#       {
#         "bindings": [
#           {
#             "authLevel": "function",
#             "type": "httpTrigger",
#             "direction": "in",
#             "name": "req",
#             "methods": [ "get" ]
#           },
#           {
#             "type": "http",
#             "direction": "out",
#             "name": "res"
#           }
#         ]
#       }


# Then compress it into a .zip:
#     zip -r functionapp.zip .      #Upload this ZIP to your Azure Storage container or public URL.
