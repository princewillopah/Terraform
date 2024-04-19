





resource "azurerm_resource_group" "my-RG" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_storage_account" "my-storage-account" {
  name                     = "princewill12"
  resource_group_name      = data.azurerm_resource_group.my-RG.name
  location                 = data.azurerm_resource_group.my-RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"  #optional

  tags = { #optional
    environment = "staging"
  }
}
 
 resource "azurerm_storage_container" "example_container" {
  name                       = "my-container"
  storage_account_name        = azurerm_storage_account.my-storage-account.name
  container_access_type = "blob" 

}

resource "azurerm_storage_blob" "storage_blob" {
for_each = {
  sample1 = "~/DevOps/Terraform/Azure/_2Storage_Account/myapp/outputs.tf"
  sample1 = "~/DevOps/Terraform/Azure/_2Storage_Account/myapp/providers.tf"
  sample1 = "~/DevOps/Terraform/Azure/_2Storage_Account/myapp/main.tf"
}
  storage_account_name   = azurerm_storage_account.my-storage-account.name
  storage_container_name = azurerm_storage_container.example_container.name
  type                   = "Block"
  source                 = "myapp.zip"

}

