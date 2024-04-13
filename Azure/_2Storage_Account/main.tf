



data "azurerm_resource_group" "my-RG" {
  name = "Prince-RG"
}

resource "azurerm_storage_account" "my-storage-account" {
  name                     = "princewill12"
  resource_group_name      = data.azurerm_resource_group.my-RG.name
  location                 = data.azurerm_resource_group.my-RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"  #optional
  # depends_on = [
  #   azurerm_resource_group.my-RG
  # ]

  tags = { #optional
    environment = "staging"
  }
}
 
 resource "azurerm_storage_container" "example_container" {
  name                       = "my-container"
  storage_account_name        = azurerm_storage_account.my-storage-account.name
  container_access_type = "blob"  # blob. container or private
  # depends_on = [
  #     azurerm_storage_account.my-storage-account
  # ]
}

resource "azurerm_storage_blob" "storage_blob" {
  name                   = "my-awesome-content.zip"
  storage_account_name   = azurerm_storage_account.my-storage-account.name
  storage_container_name = azurerm_storage_container.example_container.name
  type                   = "Block"
  source                 = "myapp.zip"
  # depends_on = [
  #     azurerm_storage_blob.storage_blob
  # ]
}

# resource "azurerm_storage_blob" "storage_blob" {
#   for_each = {
#     sample1 = "C:\\tem2\\sample1.txt"
#     sample1 = "C:\\tem2\\sample2.txt"
#     sample1 = "C:\\tem2\\sample3.txt"
#   }
#   name                   = "${each.key}.txt"
#   storage_account_name   = azurerm_storage_account.my-storage-account.name
#   storage_container_name = azurerm_storage_container.example_container.name
#   type                   = "Block"
#   source                 = each.value

# }
//////////////////////////////// others //////////////////////////////////////


# resource "azurerm_storage_share" "sharename_example" {
#   name                 = "sharename_example"
#   storage_account_name = azurerm_storage_account.my-storage-account.name
#   quota                = 5
# }
# resource "azurerm_log_analytics_workspace" "analytics_workspace_logs" {
#   name                = "acctest-01"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
# }


# resource "azurerm_container_app_environment_storage" "example" {
#   name                         = "mycontainerappstorage"
#   container_app_environment_id = azurerm_container_app_environment.example_container.id
#   account_name                 = azurerm_storage_account.my-storage-account.name
#   share_name                   = azurerm_storage_share.sharename_example.name
#   access_key                   = azurerm_storage_account.my-storage-account.primary_access_key
#   access_mode                  = "ReadOnly"
# }


# //////////////////////////////////////////////////////////////////////////////////////////

# resource "azurerm_resource_group" "rg" {
#   location = var.resource_group_location
#   name     = var.resource_group_name
# }

# resource "azurerm_storage_account" "my-storage-account" {
#   name                     = "princewill12"
#   resource_group_name      = azurerm_resource_group.my-RG.name
#   location                 = azurerm_resource_group.my-RG.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   account_kind = "StorageV2"  #optional

#   tags = { #optional
#     environment = "staging"
#   }
# }

#  resource "azurerm_storage_container" "example_container" {
#   name                       = "my-container"
#   storage_account_name        = azurerm_storage_account.my-storage-account.name
#   container_access_type = "blob"  # blob. container or private
# }

# resource "azurerm_storage_blob" "storage_blob" {
#   name                   = "my-awesome-content.zip"
#   storage_account_name   = azurerm_storage_account.my-storage-account.name
#   storage_container_name = azurerm_storage_container.example_container.name
#   type                   = "Block"
#   source                 = "myapp.zip"
# }
