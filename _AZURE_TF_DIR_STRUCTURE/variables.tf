variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "TF-State-RG"
}

variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "client_id" {
  description = "The client ID of the service principal"
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID of the Azure AD"
  type        = string
}

variable "state_key" {
  description = "The name of the state file key"
  type        = string
  default     = "projectX/dev/terraform.tfstate"
}

variable "backend_resource_group" {
  description = "The name of the resource group for the Terraform backend"
  type        = string
  default     = "TF-State-RG"
}

variable "backend_storage_account" {
  description = "The name of the storage account for the Terraform backend"
  type        = string
}

variable "backend_container" {
  description = "The name of the blob container for the Terraform backend"
  type        = string
  default     = "tfstate"
}
# variable "storage_account_name" {
#   description = "The name of the storage account for Terraform state"
#   type        = string
# }

# variable "backend_resource_group" {
#   description = "The name of the resource group for the backend"
#   type        = string
# }
# variable "backend_container" {
#   description = "The name of the container for the backend"
#   type        = string
# }
# variable "backend_storage_account" {
#   description = "The name of the storage account for the backend"
#   type        = string
# }
# variable "backend_storage_account_sas_token" {
#   description = "The SAS token for the storage account"
#   type        = string
#   default     = ""
# }
# variable "backend_storage_account_key" {
#   description = "The access key for the storage account"
#   type        = string
#   default     = ""
# }
# variable "backend_storage_account_name" {
#   description = "The name of the storage account for the backend"
#   type        = string
#   default     = ""
# }
# variable "backend_container_name" {
#   description = "The name of the container for the backend"
#   type        = string
#   default     = ""
# }
# variable "backend_key" {
#   description = "The name of the state file key"
#   type        = string
#   default     = "terraform.tfstate"
# }
# variable "backend_key_prefix" {
#   description = "The prefix for the state file key"
#   type        = string
#   default     = "projectX/dev"
# }
# variable "backend_key_suffix" {
#   description = "The suffix for the state file key"
#   type        = string
#   default     = "terraform.tfstate"
# }