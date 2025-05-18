provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "func-example-rg"
  location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = "funcexamplestorage"
  resource_group_name      = azurerm_resource_group.example.name
  location                = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = "func-premium-plan"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "EP1" # Elastic Premium 1 (smallest Premium SKU)
}

resource "azurerm_application_insights" "example" {
  name                = "func-example-insights"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type    = "web"
}

resource "azurerm_linux_function_app" "example" {
  name                = "func-example-app"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id           = azurerm_service_plan.example.id

  site_config {
    application_stack {
      node_version = "18" # or "16", "14" depending on your needs
    }
    application_insights_key = azurerm_application_insights.example.instrumentation_key
    application_insights_connection_string = azurerm_application_insights.example.connection_string
  }

  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
    "FUNCTIONS_WORKER_RUNTIME" = "node"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.example.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.example.connection_string
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_function_app_function" "example" {
  name            = "HttpTriggerFunction"
  function_app_id = azurerm_linux_function_app.example.id
  language        = "JavaScript"
  file {
    name    = "index.js"
    content = <<EOF
module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const name = (req.query.name || (req.body && req.body.name));
    const responseMessage = name
        ? "Hello, " + name + ". This HTTP triggered function executed successfully."
        : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.";

    context.res = {
        // status: 200, /* Defaults to 200 */
        body: responseMessage
    };
}
EOF
  }

  config_json = jsonencode({
    bindings = [
      {
        authLevel = "function"
        type      = "httpTrigger"
        direction = "in"
        name      = "req"
        methods   = ["get", "post"]
      },
      {
        type      = "http"
        direction = "out"
        name      = "res"
      }
    ]
  })
}