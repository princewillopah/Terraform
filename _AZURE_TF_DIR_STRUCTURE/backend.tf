terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.29.0" # Pinned with ~> for patch version updates
    }
  }

  backend "azurerm" {
    resource_group_name  = var.backend_resource_group
    storage_account_name = var.backend_storage_account
    container_name       = var.backend_container
    key                  = var.state_key
    # To initialize: Set ARM_CLIENT_ID, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_STORAGE_ACCOUNT_NAME environment variables.
    # ARM_CLIENT_SECRET should be retrieved from Key Vault (TerraformSPPassword) or set securely.
    # For disaster recovery, update storage_account_name to the backup account and re-run `terraform init`.
    # Optional: use SAS token for additional security
    # sas_token = var.storage_account_sas_token
    # Alternatively use MSI if available
    # use_azuread_auth = true
    #   lock_timeout         = "15m" # Timeout for acquiring the lock
    #   retry_wait_min_sec   = 10 # Minimum wait time before retrying
    #   retry_max_sec        = 60 # Maximum wait time before retrying

# To initialize: Set ARM_CLIENT_ID, ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_STORAGE_ACCOUNT_NAME environment variables.
# ARM_CLIENT_SECRET should be retrieved from Key Vault (TerraformSPPassword) or set securely.
# For disaster recovery, update storage_account_name to the backup account and re-run `terraform init`.
  }

  required_version = ">= 1.0.0"
}



data "azurerm_key_vault_secret" "sp_password" {
  name         = "TerraformSPPassword"
  key_vault_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
}

output "sp_password" {
  value     = data.azurerm_key_vault_secret.sp_password.value
  sensitive = true
}