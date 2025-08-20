#!/bin/bash

# Exit on error and trace
set -e
set -o pipefail



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
KEY_VAULT_NAME="tfkeyvault${TIMESTAMP}"
VNET_NAME="my-TF-Vnet"
SUBNET_NAME="${VNET_NAME}-Subnet"
PRIVATE_ENDPOINT_NAME="tfStatePrivateEndpoint"

# Validate subscription_id and public IP fetch
if [ -z "$MY_SUBSCRIPTION_ID" ]; then
  echo "Error: Could not retrieve subscription ID"
  exit 1
fi
if [ -z "$MY_IP_ADDRESS" ]; then
  echo "Error: Could not retrieve public IP address"
  exit 1
fi

# error handling to catch failures (e.g., resource group creation failing due to naming conflicts).
check_error() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}



# ----------------------------------------------------------------------------------------
# Create Primary Resource Group
# ----------------------------------------------------------------------------------------
# Check if the resource group already exists
if ! az group show --name $RESOURCE_GROUP_NAME --query id -o tsv 2>/dev/null; then
  echo "Creating resource group $RESOURCE_GROUP_NAME in $LOCATION..."
  az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --tags $TAGS
  check_error "Failed to create resource group"
else
  echo "Resource group $RESOURCE_GROUP_NAME already exists"
fi

# ----------------------------------------------------------------------------------------
#Step 2: Create Primary Storage Account for Terraform State
# ----------------------------------------------------------------------------------------
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
  --tags $TAGS 
#   --allow-cross-tenant-traffic false \
check_error "Failed to create storage account"

# ----------------------------------------------------------------------------------------
# Storage Account Hardening
# ----------------------------------------------------------------------------------------

# Enable encryption
echo "Enabling encryption..."
az storage account update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-encryption-services blob file \
  --encryption-key-source Microsoft.Storage
#   --encryption-services blob
check_error "Failed to harden storage account"

# Enable versioning | Enable container-level soft delete (account-level) | blob soft delete (for individual files like .tfstate)
echo "Configuring blob service properties..."
az storage blob service-properties update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --enable-delete-retention true \
  --delete-retention-days 30 \
  --enable-versioning true \
  --enable-change-feed true \
  --enable-restore-policy true \
  --restore-days 30 \
  --enable-soft-delete true \
  --soft-delete-retention-days 30


# -----------------------------------------------------------------------------------------
# Configure Monitoring and Auditing, Backup and Recovery
# -----------------------------------------------------------------------------------------

# Set up monitoring for state file changes:
# echo "Setting up diagnostic logs..."
# az monitor diagnostic-settings create \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --logs '[{"category": "StorageRead", "enabled": true}, {"category": "StorageWrite", "enabled": true}, {"category": "StorageDelete", "enabled": true}]' \
#   --metric-categories AllMetrics
#
LOG_ANALYTICS_WORKSPACE_NAME="tf-monitoring-logs"
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP_NAME \
  --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME \
  --location $LOCATION
check_error "Failed to create Log Analytics workspace"

# Enable diagnostic settings for the storage account
LOG_ANALYTICS_WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group $RESOURCE_GROUP_NAME --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME --query id -o tsv)
az monitor diagnostic-settings create \
  --name "tf-diagnostics" \
  --resource "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME" \
  --workspace $LOG_ANALYTICS_WORKSPACE_ID \
  --logs '[{"category": "StorageRead", "enabled": true}, {"category": "StorageWrite", "enabled": true}, {"category": "StorageDelete", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

# ----------------------------------------------------------------------------------------
# Create blob container
# ----------------------------------------------------------------------------------------
echo "Creating blob container..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --public-access off \
  --fail-on-exist

check_error "Failed to create blob container"
# ----------------------------------------------------------------------------------------
# Network Security: Restrict network access to the Storage Account:
# ----------------------------------------------------------------------------------------

# Network Security
echo "Configuring network security..."
az storage account network-rule add \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --ip-address $MY_IP_ADDRESS \
  --action Allow
az storage account update \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --default-action Deny
check_error "Failed to configure network security"


# Create VNet and Subnet (Optional)
echo "Creating VNet and Subnet..."
az network vnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --location $LOCATION
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --address-prefixes 10.0.1.0/24 \
  --service-endpoints Microsoft.Storage
az storage account network-rule add \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_NAME \
  --action Allow
check_error "Failed to configure VNet"

# Create Private Endpoint (Optional)
echo "Creating private endpoint..."
az network vnet subnet update \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --disable-private-endpoint-network-policies true
az network private-endpoint create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $PRIVATE_ENDPOINT_NAME \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_NAME \
  --private-connection-resource-id "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME" \
  --group-id blob \
  --connection-name "tfStateConnection"
check_error "Failed to create private endpoint"




## Enable network rules to Allow access from specific IP address
# echo "Configuring network access rules..."
# az storage account network-rule update \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --ip-address ${MY_IP_ADDRESS}/32 \
#   --action Allow


## Optionally allow Azure services if needed
# az storage account update \
#   --name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --bypass "AzureServices" \
#   --default-action "Deny"
# ----------------------------------------------------------------------------------------
# Configure Service Principal for Terraform
# ----------------------------------------------------------------------------------------
echo "Creating service principal..."
SP_CREDENTIALS=$(az ad sp create-for-rbac \
  --name "TerraformSP-${STORAGE_ACCOUNT_NAME}" \
  --role $IAM_ROLE \
  --scopes "/subscriptions/${MY_SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.Storage/storageAccounts/${STORAGE_ACCOUNT_NAME}/blobServices/default/containers/${CONTAINER_NAME}" \
  --years 1 \
  --query "{appId: appId, password: password, tenant: tenant}" -o json)


#Create a Service Principal for Terraform
echo "Creating service principal..."
az ad sp create-for-rbac \
  --name TerraformSP-${STORAGE_ACCOUNT_NAME} \
  --role $IAM_ROLE \
  --scopes "/subscriptions/${MY_SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP_NAME}/providers/Microsoft.Storage/storageAccounts/${STORAGE_ACCOUNT_NAME}/blobServices/default/containers/${CONTAINER_NAME}" \
  --years 1 \
  --query "{appId: appId, password: password, tenant: tenant}" -o json)

# Retrieve the Service Principal credentials
SP_APP_ID=$(echo $SP_CREDENTIALS | jq -r '.appId')
SP_PASSWORD=$(echo $SP_CREDENTIALS | jq -r '.password')
TENANT_ID=$(echo $SP_CREDENTIALS | jq -r '.tenant')


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




# ----------------------------------------------------------------------------------------
# Create a Backup Storage Account in a Different Region
# ----------------------------------------------------------------------------------------
# Create Backup Storage Account
echo "Creating backup storage account $MY_STORAGE_ACCOUNT_BACKUP..."
az group create --name $MY_STORAGE_ACCOUNT_BACKUP_RG --location westus --tags $TAGS
check_error "Failed to create backup resource group"

# Create the backup storage account
az storage account create \
  --name $MY_STORAGE_ACCOUNT_BACKUP \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --location westus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2
az storage account blob-service-properties update \
  --account-name $MY_STORAGE_ACCOUNT_BACKUP \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --enable-delete-retention true \
  --delete-retention-days 30 \
  --enable-versioning true
az storage container create --name $CONTAINER_NAME --account-name $MY_STORAGE_ACCOUNT_BACKUP
check_error "Failed to create backup storage account"

# # ----------------------------------------------------------------------------------------
# # Ensure TLS and secure access
# # ----------------------------------------------------------------------------------------
# ### Although default for Azurerm provider is secure, explicitly enforce it:

# export ARM_USE_OIDC=true
# az cloud set --name AzureCloud  # Ensure public Azure
