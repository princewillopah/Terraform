#!/bin/bash
set -e

RESOURCE_GROUP_NAME=TF-State-RG
LOCATION=eastus
STORAGE_ACCOUNT_NAME="myterraformstate$(date +%s)"  # this will create a unique name for the storage account
STORAGE_ACCOUNT_NAME="${STORAGE_ACCOUNT_NAME:0:24}"  # Azure Storage Account names must be between 3 and 24 characters long and can only contain lowercase letters and numbers
CONTAINER_NAME=tfstate
MY_IP_ADDRESS=$(curl -s ifconfig.me)  # this will retrieve the public IP address of the VM making the rquest
MY_SUBSCRIPTION_ID=$(az account show --query id -o tsv)  # this will retrieve the subscription ID of the current Azure account
IAM_ROLE="Storage Blob Data Contributor"  # this role allows the service principal to read and write to the storage account
MY_STORAGE_ACCOUNT_BACKUP_RESOURCE_GROUP=TF-State-RG-Backup
MY_STORAGE_ACCOUNT_BACKUP="mytfstatebackup$(date +%s)"
MY_STORAGE_ACCOUNT_BACKUP="${MY_STORAGE_ACCOUNT_BACKUP:0:24}"  # Azure Storage Account names must be between 3 and 24 characters long and can only contain lowercase letters and numbers
# VNET_NAME=myVnet
# SUBNET_NAME=mySubnet
# ADDITIONAL_IP_ADDRESS=<additional-ip-address>  # replace with the additional IP address you want to allow
# SERVICE_ENDPOINT=Microsoft.Storage  # replace with the service endpoint you want to allow
# PRIVATE__ENDPOINT_NAME=myPrivateEndpoint
# PRIVATE_CONNECTION_RESOURCE_ID=/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Storage/storageAccounts/<storage-account-name>  # replace with the resource ID of the private connection
# CONNECTION_NAME=myConnection

# Uncomment and set the commented variables above if you want to allow access from additional IP addresses or ranges
# and/or virtual networks
# and/or private endpoints
# and/or service endpoints
# ADDITIONAL_IP_ADDRESS=<additional-ip-address>  # replace with the additional IP address you want to allow




# ----------------------------------------------------------------------------------------
# Create Resource Group
# ----------------------------------------------------------------------------------------
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION


# ----------------------------------------------------------------------------------------
#Step 2: Create a Storage Account for Terraform State
# ----------------------------------------------------------------------------------------
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \                              
  --allow-blob-public-access false \
  --default-action Deny \
  --min-tls-version TLS1_2 \
  --allow-cross-tenant-traffic false

# ----------------------------------------------------------------------------------------
# Storage Account Hardening
# ----------------------------------------------------------------------------------------

# Enable encryption
az storage account update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-encryption-services blob \
  --encryption-services blob

# Step 3: Enable Blob Soft Delete
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-delete-retention true \
  --delete-retention-days 30

# Enable versioning
az storage blob service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-versioning true


# -----------------------------------------------------------------------------------------
# Enable state locking to prevent concurrent modifications:
# -----------------------------------------------------------------------------------------

# az storage account blob-service-properties update \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --enable-lock true

## There’s no such --enable-lock true property in az storage account blob-service-properties update.
## Terraform state locking is handled by Azure Storage Account’s Blob Leases, not a direct property. You don’t need this command — remove it
# -----------------------------------------------------------------------------------------
# Configure Monitoring and Auditing, Backup and Recovery
# -----------------------------------------------------------------------------------------

# Set up monitoring for state file changes:
az monitor diagnostic-settings create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --logs '[{"category": "StorageRead", "enabled": true}, {"category": "StorageWrite", "enabled": true}, {"category": "StorageDelete", "enabled": true}]' \
  --metric-categories AllMetrics


# # Configure Backup and Recovery for the Storage Account
# az storage account blob-service-properties update \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --enable-soft-delete true \
#   --soft-delete-retention-days 30


# ----------------------------------------------------------------------------------------
# Create blob container
# ----------------------------------------------------------------------------------------
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME


# ----------------------------------------------------------------------------------------
# Network Security: Restrict network access to the Storage Account:
# ----------------------------------------------------------------------------------------

# Enable network rules to Allow access from specific IP address
az storage account network-rule update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --ip-address $MY_IP_ADDRESS \
  --action Allow

# # Set default action to Deny
# az storage account network-rule update \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --default-action Deny

# # (Optional) Allow access from additional IP address or range
# az storage account network-rule add \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --ip-address $ADDITIONAL_IP_ADDRESS \
#   --action Allow

# # (Optional) Allow access from a specific virtual network
# az storage account network-rule add \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --vnet-name $VNET_NAME \
#   --subnet $SUBNET_NAME \
#   --action Allow

# # Enable private endpoint
# az storage account private-endpoint-connection create \
#   --name $PRIVATE__ENDPOINT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --account-name $STORAGE_ACCOUNT_NAME \
#   --subnet $SUBNET_NAME \
#   --private-connection-resource-id $PRIVATE_CONNECTION_RESOURCE_ID \
#   --group-id blob \
#   --connection-name $CONNECTION_NAME

# # (Optional) Allow access from specific Azure services
# az storage account network-rule add \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --service-endpoint $SERVICE_ENDPOINT \
#   --action Allow






# ----------------------------------------------------------------------------------------
# Configure Service Principal for Terraform
# ----------------------------------------------------------------------------------------



#Create a Service Principal for Terraform
az ad sp create-for-rbac \
  --name TerraformSP \
  --role $IAM_ROLE \
  --scopes /subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME


# Step 6: Retrieve the Service Principal credentials
SP_CREDENTIALS=$(az ad sp credential reset --name TerraformSP --query "{appId: appId, password: password}" -o json)
SP_APP_ID=$(echo $SP_CREDENTIALS | jq -r '.appId')
SP_PASSWORD=$(echo $SP_CREDENTIALS | jq -r '.password')
echo "Service Principal App ID: $SP_APP_ID"
echo "Service Principal Password: $SP_PASSWORD"

# Assign the $IAM_ROLE role to the Service Principal:
SP_OBJECT_ID=$(az ad sp show --id $SP_APP_ID --query objectId -o tsv)
az role assignment create \
  --assignee-object-id $SP_OBJECT_ID \
  --role "$IAM_ROLE" \
  --scope "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"


TENANT_ID=$(az account show --query tenantId -o tsv)

echo "Set the following environment variables before running terraform:"
echo "export ARM_CLIENT_ID=\"$SP_APP_ID\""
echo "export ARM_CLIENT_SECRET=\"$SP_PASSWORD\""
echo "export ARM_SUBSCRIPTION_ID=\"$MY_SUBSCRIPTION_ID\""
echo "export ARM_TENANT_ID=\"$TENANT_ID\""




# ----------------------------------------------------------------------------------------
# Create a Backup Storage Account in a Different Region
# ----------------------------------------------------------------------------------------

az group create --name $MY_STORAGE_ACCOUNT_BACKUP_RESOURCE_GROUP --location westus

az storage account create \
  --name $MY_STORAGE_ACCOUNT_BACKUP \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RESOURCE_GROUP \
  --location westus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --allow-blob-public-access false \
  --default-action Deny \
  --min-tls-version TLS1_2 \
  --allow-cross-tenant-traffic false

# ----------------------------------------------------------------------------------------
# Ensure TLS and secure access
# ----------------------------------------------------------------------------------------
### Although default for Azurerm provider is secure, explicitly enforce it:

export ARM_USE_OIDC=true
az cloud set --name AzureCloud  # Ensure public Azure

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------
# 
# ----------------------------------------------------------------------------------------