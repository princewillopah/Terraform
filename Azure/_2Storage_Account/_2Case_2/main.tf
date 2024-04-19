





resource "azurerm_resource_group" "my-RG" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_storage_account" "my-storage-account" {
  name                     = "princewill123"
  resource_group_name      = azurerm_resource_group.my-RG.name
  location                 = azurerm_resource_group.my-RG.location
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

# resource "azurerm_storage_blob" "storage_blob" {
# for_each = {
#   outputs = "~/DevOps/Terraform/Azure/_2Storage_Account/_2Case_2/myapp/outputs.tf"
#   providers = "~/DevOps/Terraform/Azure/_2Storage_Account/_2Case_2/myapp/providers.tf"
#   main = "~/DevOps/Terraform/Azure/_2Storage_Account/_2Case_2/myapp/main.tf"
# }
#   name = "${each.key}.tf"
#   storage_account_name   = azurerm_storage_account.my-storage-account.name
#   storage_container_name = azurerm_storage_container.example_container.name
#   type                   = "Block"
#   source                 = each.value // "~/DevOps/Terraform/Azure/_2Storage_Account/myapp/outputs.tf", "~/DevOps/Terraform/Azure/_2Storage_Account/myapp/providers.tf", "~/DevOps/Terraform/Azure/_2Storage_Account/myapp/main.tf"

# }

resource "azurerm_storage_blob" "storage_blob" {
  for_each = {
    "outputs"   = "myapp/outputs.tf"
    "providers" = "myapp/providers.tf"
    "main"      = "myapp/main.tf"
  }
  name                   = "${each.key}.tf"
  storage_account_name   = azurerm_storage_account.my-storage-account.name
  storage_container_name = azurerm_storage_container.example_container.name
  type                   = "Block"
  source                 = "${path.module}/${each.value}" // ${path.module} is a special variable that represents the path to the directory containing the current Terraform configuration file (usually referred to as the "module root").// i use ${path.module}/${each.value} to construct the full relative path to each file.
}