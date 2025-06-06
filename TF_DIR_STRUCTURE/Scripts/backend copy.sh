#!/bin/bash

RESOURCE_GROUP_NAME=TF-State-RG
STORAGE_ACCOUNT_NAME=myterraformstate$RANDOM
CONTAINER_NAME=tfstate

# Generate a random storage account name
# The name must be between 3 and 24 characters in length and can contain only lowercase letters and numbers.
# The name must start with a letter and must be unique within Azure.



# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location eastus

# Create storage account
# az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob



## Step 2: Create a Storage Account for Terraform State

# az storage account create \
#   --name mystorageaccount \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --location eastus \
#   --sku Standard_LRS \
#   --kind StorageV2 \
#   --https-only true \
#   --allow-blob-public-access false \
#   --default-action Deny \
#   --min-tls-version TLS1_2 \
#   --allow-cross-tenant-traffic false
# ----------------------------------------------------------------------------------------
# Storage Account Hardening
# ----------------------------------------------------------------------------------------

# # Enable encryption
# az storage account update \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --enable-encryption-services blob \
#   --encryption-services blob

# # Enable network rules
# az storage account network-rule add \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --ip-address <your-ip-address> \
#   --action Allow

# Enable logging and monitoring
az storage logging update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --log rwd \
  --retention 7 \
  --services b \
  --metrics true

# # Enable soft delete
# az storage blob service-properties update \
#   --account-name $STORAGE_ACCOUNT_NAME \
#   --enable-soft-delete true \
#   --soft-delete-retention-days 7

# Enable versioning
az storage blob service-properties update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --enable-versioning true

# Enable firewall and virtual network rules
az storage account network-rule add \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name <your-vnet-name> \
  --subnet <your-subnet-name> \
  --action Allow

# Enable private endpoint
az storage account private-endpoint-connection create \
  --name <your-private-endpoint-name> \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --subnet <your-subnet-name> \
  --private-connection-resource-id <your-private-connection-resource-id> \
  --group-id blob \
  --connection-name <your-connection-name>

# Enable service endpoints
az storage account network-rule add \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --service-endpoint <your-service-endpoint> \
  --action Allow

# Enable Azure Defender for Storage
az security auto-provisioning-setting update \
  --resource-group $RESOURCE_GROUP_NAME \
  --storage-account $STORAGE_ACCOUNT_NAME \
  --auto-provision true

# Enable Azure Policy for Storage
az policy assignment create \
  --name <your-policy-name> \
  --scope /subscriptions/<your-subscription-id>/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME \
  --policy <your-policy-definition-id>

# Enable Azure Monitor for Storage
az monitor diagnostic-settings create \
  --name <your-diagnostic-settings-name> \
  --resource-id /subscriptions/<your-subscription-id>/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME \
  --workspace <your-log-analytics-workspace-id> \
  --metrics '[{"category": "AllMetrics", "enabled": true, "retentionPolicy": {"enabled": false, "days": 0}}]' \
  --logs '[{"category": "StorageRead", "enabled": true, "retentionPolicy": {"enabled": false, "days": 0}}]'


# Enable secure transfer
az storage account update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --https-only true

# Enable blob public access
az storage account update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --allow-blob-public-access false

# Enable minimum TLS version
az storage account update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --min-tls-version TLS1_2

# Enable blob versioning
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-versioning true

# Enable blob soft delete
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-soft-delete true \
  --soft-delete-retention-days 7

# Enable blob lifecycle management
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-lifecycle-management true

# Enable blob inventory
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-inventory true

# Enable blob auditing
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-auditing true

# Enable blob encryption
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-encryption true

# Enable blob access tiers
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-access-tiers true

# Enable blob immutability
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-immutability true
  
# Enable blob change feed
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-change-feed true


# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
# Get storage account key
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' --output tsv)
# Create backend configuration file
cat <<EOF > backend.tf
terraform {
  backend "azurerm" {
    resource_group_name   = "$RESOURCE_GROUP_NAME"
    storage_account_name  = "$STORAGE_ACCOUNT_NAME"
    container_name        = "$CONTAINER_NAME"
    key                   = "terraform.tfstate"
  }
}
EOF
# Initialize Terraform
terraform init
# Create a new file named backend.tf in your Terraform configuration directory and add the following content:
# This file configures the backend for storing the Terraform state file in Azure Blob Storage.
# The resource_group_name, storage_account_name, and container_name should match the values you used when creating the storage account and container.
# The key is the name of the state file that will be created in the container.
# The terraform init command initializes the Terraform working directory and configures the backend.
# This command will prompt you to enter the storage account key. You can retrieve it using the Azure CLI or Azure Portal.
# After entering the key, Terraform will create the state file in the specified Azure Blob Storage container.
# You can verify that the state file has been created by checking the Azure Portal or using the Azure CLI to list the blobs in the container.
# az storage blob list --account-name $STORAGE_ACCOUNT_NAME --container-name $CONTAINER_NAME --output table
# This command will list all the blobs in the specified container, including the Terraform state file.  

