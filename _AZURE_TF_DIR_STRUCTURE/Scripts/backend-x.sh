#!/bin/bash

# Exit on error and trace
set -e
set -o pipefail

# Logging setup
LOG_FILE="backend_setup_$(date +%F_%H-%M-%S).log"
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
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
check_error "Failed to create storage account"

# ----------------------------------------------------------------------------------------
# Storage Account Hardening
# ----------------------------------------------------------------------------------------

# Enable encryption
echo "Enabling encryption..."
az storage account update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --encryption-services blob file \
  --encryption-key-source Microsoft.Storage
check_error "Failed to harden storage account"

# Enable versioning | Enable container-level soft delete (account-level) | blob soft delete (for individual files like .tfstate)
# echo "Configuring blob service properties..."
# az storage blob service-properties update \
#   --account-name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --enable-delete-retention true \
#   --delete-retention-days 30 \
#   --enable-versioning true \
#   --enable-change-feed true \
#   --enable-restore-policy true \
#   --restore-days 30 \
#   --enable-soft-delete true \
#   --soft-delete-retention-days 30

# ----------------------------------------------------------------------------------------
# Configure Blob Service Properties
# ----------------------------------------------------------------------------------------
echo "Configuring blob service properties for $STORAGE_ACCOUNT_NAME..."

# Enable blob versioning
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --enable-versioning true 
check_error "Failed to enable blob versioning"
az storage blob service-properties update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --delete-retention true \
  --delete-retention-period 30 
check_error "Failed to enable blob soft delete"


# Note: Container soft delete and change feed are not supported in this Azure CLI version.
echo "WARNING: Container soft delete not configured. To enable, go to the Azure Portal > Storage Account > Data protection, and enable 'Container soft delete' with a 30-day retention period."
echo "WARNING: Blob change feed not configured. To enable, go to the Azure Portal > Storage Account > Data management > Change feed, and toggle it to 'On'."

# Note: Restore policy is automatically enabled when versioning and soft delete are enabled.
# No separate command is needed for restore policy, as it is tied to versioning and soft delete retention.
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
#--------------------------------------------------
# echo "Creating LOG_ANALYTICS_WORKSPACE"
# LOG_ANALYTICS_WORKSPACE_NAME="tf-monitoring-logs"
# az monitor log-analytics workspace create \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME \
#   --location $LOCATION
# check_error "Failed to create Log Analytics workspace"

# echo "LOG_ANALYTICS_WORKSPACE id."
# # Enable diagnostic settings for the storage account
# # Enable diagnostic settings for the storage account
# LOG_ANALYTICS_WORKSPACE_ID=$(az monitor log-analytics workspace show --resource-group $RESOURCE_GROUP_NAME --workspace-name $LOG_ANALYTICS_WORKSPACE_NAME --query id -o tsv)
# az monitor diagnostic-settings create \
#   --name "tf-diagnostics" \
#   --resource "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME" \
#   --workspace $LOG_ANALYTICS_WORKSPACE_ID \
#   --logs '[{category:StorageWrite,enabled:true,retention-policy:{enabled:false,days:0}},{category:StorageDelete,enabled:true,retention-policy:{enabled:false,days:0}}]' \
#   --metrics '[{category:AllMetrics,enabled:true,retention-policy:{enabled:false,days:0}}]'
# check_error "Failed to create diagnostic settings"

echo "WARNING: Diagnostic settings not configured due to unsupported log categories. Configure manually in Azure Portal if needed."
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
# Get VM's current public IP
echo "Fetching VM public IP..."
MY_IP=$(curl -s ifconfig.me)
if [ -z "$MY_IP" ]; then
  echo "ERROR: Failed to fetch public IP. Please check network connectivity or try an alternative IP fetch method."
  exit 1
fi
echo "VM public IP is: $MY_IP"
# Add IP to primary storage account firewall
echo "Adding IP $MY_IP to storage account $STORAGE_ACCOUNT_NAME firewall..."
az storage account network-rule add \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --ip-address $MY_IP \
  --action Allow
check_error "Failed to add IP to primary storage account firewall"
# Set default action to Deny
az storage account update \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --default-action Deny
check_error "Failed to configure primary storage account network security"
# Add IP to backup storage account firewall
echo "Adding IP $MY_IP to backup storage account $MY_STORAGE_ACCOUNT_BACKUP firewall..."
az storage account network-rule add \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --account-name $MY_STORAGE_ACCOUNT_BACKUP \
  --ip-address $MY_IP \
  --action Allow
check_error "Failed to add IP to backup storage account firewall"
az storage account update \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --name $MY_STORAGE_ACCOUNT_BACKUP \
  --default-action Deny
check_error "Failed to configure backup storage account network security"

# # Create VNet and Subnet (Optional)
# echo "Creating VNet and Subnet..."
# az network vnet create \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --name $VNET_NAME \
#   --address-prefix 10.0.0.0/16 \
#   --location $LOCATION
# az network vnet subnet create \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --vnet-name $VNET_NAME \
#   --name $SUBNET_NAME \
#   --address-prefixes 10.0.1.0/24 \
#   --service-endpoints Microsoft.Storage
# az storage account network-rule add \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --account-name $STORAGE_ACCOUNT_NAME \
#   --vnet-name $VNET_NAME \
#   --subnet $SUBNET_NAME \
#   --action Allow
# check_error "Failed to configure VNet"

# # Create Private Endpoint (Optional)
# echo "Creating private endpoint..."
# az network vnet subnet update \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --vnet-name $VNET_NAME \
#   --name $SUBNET_NAME \
#   --disable-private-endpoint-network-policies true
# az network private-endpoint create \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --name $PRIVATE_ENDPOINT_NAME \
#   --vnet-name $VNET_NAME \
#   --subnet $SUBNET_NAME \
#   --private-connection-resource-id "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME" \
#   --group-id blob \
#   --connection-name "tfStateConnection"
# check_error "Failed to create private endpoint"




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
# Configure Service Principal
echo "Creating service principal..."
SP_NAME="TerraformSP"
az ad sp create --display-name $SP_NAME
SP_APP_ID=$(az ad sp list --display-name $SP_NAME --query '[0].appId' -o tsv)
az ad sp credential reset --id $SP_APP_ID --append --query password -o tsv > sp_password.txt
check_error "Failed to create service principal"
echo "Service Principal App ID: $SP_APP_ID"

# Store Credentials in Key Vault
echo "Storing credentials in Key Vault..."
az keyvault create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $KEY_VAULT_NAME \
  --location $LOCATION
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "TerraformSPPassword" \
  --value "$(cat sp_password.txt)"
rm sp_password.txt
check_error "Failed to store credentials in Key Vault"

# Grant Service Principal access to Key Vault secrets
echo "Granting service principal access to Key Vault..."
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --spn $SP_APP_ID \
  --secret-permissions get list
check_error "Failed to set Key Vault policy"

# Assign Role
echo "Assigning role to service principal..."
az role assignment create \
  --assignee $SP_APP_ID \
  --role "$IAM_ROLE" \
  --scope "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"
check_error "Failed to assign role"




# ----------------------------------------------------------------------------------------
# Create a Backup Storage Account in a Different Region
# ----------------------------------------------------------------------------------------
# Create Backup Storage Account
echo "Creating backup storage account $MY_STORAGE_ACCOUNT_BACKUP..."
az group create --name $MY_STORAGE_ACCOUNT_BACKUP_RG --location westus --tags $TAGS
check_error "Failed to create backup resource group"

az storage account create \
  --name $MY_STORAGE_ACCOUNT_BACKUP \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --location westus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --tags $TAGS
check_error "Failed to create backup storage account"
# Enable encryption
# az storage account blob-service-properties update \
#   --account-name $MY_STORAGE_ACCOUNT_BACKUP \
#   --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
#   --enable-delete-retention true \
#   --delete-retention-days 30 \
#   --enable-versioning true \
#   --enable-change-feed true \
#   --enable-restore-policy true \
#   --restore-days 30 \
#   --enable-soft-delete true \
#   --soft-delete-retention-days 30

# ----------------------------------------------------------------------------------------
# Configure Backup Storage Account Blob Service Properties
# ----------------------------------------------------------------------------------------
# Enable encryption
echo "Enabling encryption..."
az storage account update \
  --name $MY_STORAGE_ACCOUNT_BACKUP \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --encryption-services blob file \
  --encryption-key-source Microsoft.Storage
check_error "Failed to harden storage account"
echo "Configuring blob service properties for backup storage account $MY_STORAGE_ACCOUNT_BACKUP..."

# Configure Backup Storage Account Blob Service Properties
echo "Configuring blob service properties for backup storage account $MY_STORAGE_ACCOUNT_BACKUP..."
az storage account blob-service-properties update \
  --account-name $MY_STORAGE_ACCOUNT_BACKUP \
  --enable-versioning true 
check_error "Failed to enable blob versioning for backup storage account"
az storage blob service-properties update \
  --account-name $MY_STORAGE_ACCOUNT_BACKUP \
  --delete-retention true \
  --delete-retention-period 30 
check_error "Failed to enable blob soft delete for backup storage account"
echo "WARNING: Container soft delete not configured for backup storage account. To enable, go to Azure Portal > Storage Account > Data protection, enable 'Container soft delete' with 30-day retention."
echo "WARNING: Blob change feed not configured for backup storage account. To enable, go to Azure Portal > Storage Account > Data management > Change feed, toggle to 'On'."
# # ----------------------------------------------------------------------------------------
# # create container in backup storage account
# # ----------------------------------------------------------------------------------------
az storage container create --name $CONTAINER_NAME --account-name $MY_STORAGE_ACCOUNT_BACKUP
check_error "Failed to create backup storage account"

# # ----------------------------------------------------------------------------------------
# # Ensure TLS and secure access
# # ----------------------------------------------------------------------------------------


log "Configuring network security for backup storage account..."
az storage account network-rule add \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --account-name $MY_STORAGE_ACCOUNT_BACKUP \
  --ip-address $MY_IP_ADDRESS \
  --action Allow
az storage account update \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --name $MY_STORAGE_ACCOUNT_BACKUP \
  --default-action Deny
check_error "Failed to configure backup storage account network security"

log "Configuring blob replication for disaster recovery..."
az storage blob copy start \
  --account-name $STORAGE_ACCOUNT_NAME \
  --source-container $CONTAINER_NAME \
  --destination-container $CONTAINER_NAME \
  --destination-account-name $MY_STORAGE_ACCOUNT_BACKUP
check_error "Failed to initiate blob replication"

# Output Environment Variables
log "Environment variables for Terraform:"
log "export ARM_CLIENT_ID=$SP_APP_ID"
log "export ARM_CLIENT_SECRET=\$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name TerraformSPPassword --query value -o tsv)"
log "export ARM_SUBSCRIPTION_ID=$MY_SUBSCRIPTION_ID"
log "export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)"
log "export ARM_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME"
log "Run these commands before executing 'terraform init'."



# ### Although default for Azurerm provider is secure, explicitly enforce it:

# export ARM_USE_OIDC=true
# az cloud set --name AzureCloud  # Ensure public Azure
