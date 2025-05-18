# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  name     = "example-function-app-rg"
  location = "West US"
}

# Create a Storage Account for the Function App
resource "azurerm_storage_account" "example" {
  name                     = "examplestorage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an Application Insights instance
resource "azurerm_application_insights" "example" {
  name                = "example-appinsights"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "Node.JS"
}

# Create a Premium App Service Plan
resource "azurerm_service_plan" "example" {
  name                = "example-premium-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "EP1" # Premium Elastic Plan (EP1 is the smallest Premium tier)
}

# Create a Linux Function App with Node.js runtime
resource "azurerm_linux_function_app" "example" {
  name                       = "example-function-app-${random_string.suffix.result}"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  service_plan_id            = azurerm_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key

  site_config {
    application_stack {
      node_version = "18" # Node.js version
    }
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "18"
    "FUNCTIONS_WORKER_RUNTIME"     = "node"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.example.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.example.connection_string
  }
}

# Random string for unique resource names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create a ZIP file for the Node.js HTTP trigger function
data "archive_file" "function_code" {
  type        = "zip"
  output_path = "${path.module}/function-app.zip"

  source {
    content  = <<EOF
// index.js
module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const name = (req.query.name || (req.body && req.body.name));
    const responseMessage = name
        ? "Hello, " + name + ". This HTTP triggered function executed successfully."
        : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.";

    context.res = {
        status: 200,
        body: responseMessage
    };
}
EOF
    filename = "HttpTrigger/index.js"
  }

  source {
    content  = <<EOF
{
  "bindings": [
    {
      "authLevel": "anonymous",
      "type": "httpTrigger",
      "direction": "in",
      "name": "req",
      "methods": [
        "get",
        "post"
      ]
    },
    {
      "type": "http",
      "direction": "out",
      "name": "res"
    }
  ]
}
EOF
    filename = "HttpTrigger/function.json"
  }

  source {
    content  = <<EOF
{
  "version": "2.0",
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle",
    "version": "[4.*, 5.0.0)"
  }
}
EOF
    filename = "host.json"
  }
}

# Deploy the Node.js function code to the Function App
resource "azurerm_function_app_function" "example" {
  name            = "HttpTrigger"
  function_app_id = azurerm_linux_function_app.example.id
  language        = "JavaScript"

  file {
    name    = "function-app.zip"
    content = data.archive_file.function_code.output_base64
  }
}