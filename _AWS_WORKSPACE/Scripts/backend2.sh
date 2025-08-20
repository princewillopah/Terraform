#!/bin/bash

# Exit on error and trace
set -e
set -o pipefail

# error handling to catch failures (e.g., resource group creation failing due to naming conflicts).
check_error() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Ensure jq is installed
command -v jq >/dev/null 2>&1 || { echo >&2 "Error: jq is not installed. Please install it first."; exit 1; }

# Variables
TIMESTAMP=$(date +%s | tail -c 6)  # Use last 6 digits of timestamp
RESOURCE_GROUP_NAME=TF-State-RG
LOCATION=eastus
STORAGE_ACCOUNT_NAME="mytfstate${TIMESTAMP}" # Create a unique name for the storage account
STORAGE_ACCOUNT_NAME=$(echo $STORAGE_ACCOUNT_NAME | tr '[:upper:]' '[:lower:]' | cut -c 1-24)  # Azure limit: 3–24 chars, lowercase, numbers - Ensure the name is lowercase and within length limits:
CONTAINER_NAME=tfstate
MY_IP_ADDRESS=$(curl -s ifconfig.me)
MY_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
IAM_ROLE="Storage Blob Data Contributor"
MY_STORAGE_ACCOUNT_BACKUP_RG=TF-State-RG-Backup
MY_STORAGE_ACCOUNT_BACKUP="mytfstatebackup${TIMESTAMP}"
MY_STORAGE_ACCOUNT_BACKUP=$(echo $MY_STORAGE_ACCOUNT_BACKUP | tr '[:upper:]' '[:lower:]' | cut -c 1-24)  # Azure limit: 3–24 chars, lowercase, numbers - Ensure the name is lowercase and within length limits:
TAGS="Environment=Production Owner=Terraform Team"

# Validate subscription_id and public IP fetch
if [ -z "$MY_SUBSCRIPTION_ID" ]; then
  echo "Error: Could not retrieve subscription ID"
  exit 1
fi
if [ -z "$MY_IP_ADDRESS" ]; then
  echo "Error: Could not retrieve public IP address"
  exit 1
fi

# Create primary resource group
if ! az group show --name $RESOURCE_GROUP_NAME --query id -o tsv 2>/dev/null; then
  echo "Creating resource group $RESOURCE_GROUP_NAME in $LOCATION..."
  az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --tags $TAGS
  check_error "Failed to create resource group"
else
  echo "Resource group $RESOURCE_GROUP_NAME already exists"
fi

# Create primary storage account
echo "Creating primary storage account..."
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
  --tags $TAGS

# Enable encryption
echo "Enabling encryption..."
az storage account update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-encryption-services blob \
  --encryption-services blob

# Enable blob soft delete (for individual files like .tfstate)
echo "Enabling blob-level soft delete..."
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-delete-retention true \
  --delete-retention-days 30

# Enable container-level soft delete (account-level)
echo "Enabling account-level soft delete..."
az storage account blob-service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-soft-delete true \
  --soft-delete-retention-days 30

# Enable versioning
echo "Enabling versioning..."
az storage blob service-properties update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-versioning true

# Set up monitoring
echo "Setting up diagnostic logs..."
az monitor diagnostic-settings create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --logs '[{"category": "StorageRead", "enabled": true}, {"category": "StorageWrite", "enabled": true}, {"category": "StorageDelete", "enabled": true}]' \
  --metric-categories AllMetrics

# Create container
echo "Creating blob container..."
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

# Configure network rules
echo "Configuring network access rules..."
az storage account network-rule update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --ip-address ${MY_IP_ADDRESS}/32 \
  --action Allow

# Create service principal
echo "Creating service principal..."
az ad sp create-for-rbac \
  --name TerraformSP \
  --role $IAM_ROLE \
  --scopes "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"

# Get credentials
SP_CREDENTIALS=$(az ad sp credential reset --name TerraformSP --query "{appId: appId, password: password}" -o json)
SP_APP_ID=$(echo $SP_CREDENTIALS | jq -r '.appId')
SP_PASSWORD=$(echo $SP_CREDENTIALS | jq -r '.password')

# Assign role using objectId
SP_OBJECT_ID=$(az ad sp show --id $SP_APP_ID --query objectId -o tsv)
az role assignment create \
  --assignee-object-id $SP_OBJECT_ID \
  --role "$IAM_ROLE" \
  --scope "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"

# Output env vars for Terraform
TENANT_ID=$(az account show --query tenantId -o tsv)

echo ""
echo "✅ Done! Now set these environment variables before running terraform:"
echo ""
echo "export ARM_CLIENT_ID=\"$SP_APP_ID\""
echo "export ARM_CLIENT_SECRET=\"$SP_PASSWORD\""
echo "export ARM_SUBSCRIPTION_ID=\"$MY_SUBSCRIPTION_ID\""
echo "export ARM_TENANT_ID=\"$TENANT_ID\""
echo "export ARM_USE_OIDC=true"
echo "export ARM_ENVIRONMENT=public"
echo ""

# Create backup storage account
echo "Creating backup resource group and storage account..."
az group create --name $MY_STORAGE_ACCOUNT_BACKUP_RG --location westus
az storage account create \
  --name $MY_STORAGE_ACCOUNT_BACKUP \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --location westus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --allow-blob-public-access false \
  --default-action Deny \
  --min-tls-version TLS1_2 \
  --tags $TAGS
  # --allow-cross-tenant-traffic false
  
echo ""
echo "✅ Remote state storage setup completed successfully!"