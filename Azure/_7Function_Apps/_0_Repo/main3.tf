Here's a sample Terraform code to create a Function App with Node.js, HTTP trigger, Premium plan, and Application Insights:

```
terraform
provider "azurerm" {
  version = "2.34.0"
  subscription_id = "your_subscription_id"
  client_id      = "your_client_id"
  client_secret   = "your_client_secret"
  tenant_id       = "your_tenant_id"
}

resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "West US"
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-app-service-plan"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = "elastic"
  sku {
    tier = "Premium"
    size = "P1v2"
  }
}

resource "azurerm_application_insights" "example" {
  name                = "example-application-insights"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  application_type   = "web"
}

resource "azurerm_function_app" "example" {
  name                       = "example-function-app"
  resource_group_name       = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  app_service_plan_id       = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  os_type                    = "linux"
  version                    = "~3"

  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "~14"
    FUNCTIONS_WORKER_RUNTIME      = "node"
    FUNCTION_APP_EDIT_MODE        = "readwrite"
    https_only                     = "true"
  }
}

resource "azurerm_function_app_function" "example" {
  name            = "example-function"
  function_app_id = azurerm_function_app.example.id
  language        = "javascript"
  handler         = "index.handler"

  file {
    name    = "index.js"
    content = <<EOF
module.exports = async function (context, req) {
  context.log('JavaScript HTTP trigger function processed a request.');
  const name = (req.query.name || (req.body && req.body.name));
  const responseMessage = name ? "Hello, " + name + ". This HTTP triggered function executed successfully." : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.";
  context.res = {
    body: responseMessage
  };
}
EOF
  }
}

resource "azurerm_function_app_function" "example_trigger" {
  name            = "example-trigger"
  function_app_id = azurerm_function_app.example.id
  language        = "javascript"
  handler         = "index.handler"

  trigger_http {
    methods = ["GET", "POST"]
    route   = "example-trigger"
  }
}
```