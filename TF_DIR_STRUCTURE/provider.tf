provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = data.azurerm_key_vault_secret.sp_password.value
  tenant_id       = var.tenant_id
}

data "azurerm_key_vault_secret" "sp_password" {
  name         = "TerraformSPPassword"
  key_vault_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
}

output "sp_password" {
  value     = data.azurerm_key_vault_secret.sp_password.value
  sensitive = true
}