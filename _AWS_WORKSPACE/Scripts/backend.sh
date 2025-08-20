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
STORAGE_ACCOUNT_NAME=$(echo $STORAGE_ACCOUNT_NAME | tr '[:upper:]' '[:lower:]' | cut -c 1-24)  # Azure limit: 3–24 chars, lowercase, numbers
CONTAINER_NAME=tfstate
MY_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
IAM_ROLE="Storage Blob Data Contributor"
MY_STORAGE_ACCOUNT_BACKUP_RG=TF-State-RG-Backup
MY_STORAGE_ACCOUNT_BACKUP="mytfstatebackup${TIMESTAMP}"
MY_STORAGE_ACCOUNT_BACKUP=$(echo $MY_STORAGE_ACCOUNT_BACKUP | tr '[:upper:]' '[:lower:]' | cut -c 1-24)  # Azure limit: 3–24 chars, lowercase, numbers
TAGS="Environment=Production Owner=Terraform Team"
KEY_VAULT_NAME="tfkeyvault${TIMESTAMP}"
VNET_NAME="my-TF-Vnet"
SUBNET_NAME="${VNET_NAME}-Subnet"
PRIVATE_ENDPOINT_NAME="tfStatePrivateEndpoint"

# Validate subscription_id
if [ -z "$MY_SUBSCRIPTION_ID" ]; then
  echo "Error: Could not retrieve subscription ID"
  exit 1
fi

# Error handling
check_error() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Create Primary Resource Group
if ! az group show --name $RESOURCE_GROUP_NAME --query id -o tsv 2>/dev/null; then
  echo "Creating resource group $RESOURCE_GROUP_NAME in $LOCATION..."
  az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --tags $TAGS
  check_error "Failed to create resource group"
else
  echo "Resource group $RESOURCE_GROUP_NAME already exists"
fi

# Create Primary Storage Account
echo "Creating primary storage account..."
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --tags $TAGS
check_error "Failed to create storage account"

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

# Network Security
echo "Configuring network security..."
# Get VM's current public IP
echo "Fetching VM public IP..."
MY_IP=$(curl -s ifconfig.me || curl -s https://api.ipify.org)
if [ -z "$MY_IP" ]; then
  echo "ERROR: Failed to fetch public IP. Please check network connectivity or manually specify your VM's public IP."
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

# Create Blob Container (Primary)
echo "Creating blob container..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --public-access off \
  --fail-on-exist
check_error "Failed to create blob container"

# Create Blob Container (Backup)
echo "Creating blob container for backup storage account..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $MY_STORAGE_ACCOUNT_BACKUP \
  --public-access off \
  --fail-on-exist
check_error "Failed to create backup storage account container"

# Enable Encryption (Primary)
echo "Enabling encryption..."
az storage account update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --encryption-services blob file \
  --encryption-key-source Microsoft.Storage
check_error "Failed to harden storage account"

# Configure Blob Service Properties (Primary)
echo "Configuring blob service properties for $STORAGE_ACCOUNT_NAME..."
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --enable-versioning true
check_error "Failed to enable blob versioning"
az storage blob service-properties update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --delete-retention true \
  --delete-retention-period 30
check_error "Failed to enable blob soft delete"
echo "WARNING: Container soft delete not configured. To enable, go to the Azure Portal > Storage Account > Data protection, and enable 'Container soft delete' with a 30-day retention period."
echo "WARNING: Blob change feed not configured. To enable, go to the Azure Portal > Storage Account > Data management > Change feed, and toggle it to 'On'."

# Enable Encryption (Backup)
echo "Enabling encryption for backup storage account..."
az storage account update \
  --name $MY_STORAGE_ACCOUNT_BACKUP \
  --resource-group $MY_STORAGE_ACCOUNT_BACKUP_RG \
  --encryption-services blob file \
  --encryption-key-source Microsoft.Storage
check_error "Failed to harden backup storage account"

# Configure Blob Service Properties (Backup)
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

# Commented-Out Diagnostic Settings
echo "WARNING: Diagnostic settings not configured due to unsupported log categories. Configure manually in Azure Portal if needed."

# Configure Service Principal
# Configure Service Principal
echo "Creating service principal..."
SP_NAME="TerraformSP"
SP_OUTPUT=$(az ad sp create-for-rbac --name $SP_NAME --role "$IAM_ROLE" --scopes "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME" --query "{appId:appId,password:password}" -o json)
check_error "Failed to create service principal"
SP_APP_ID=$(echo $SP_OUTPUT | jq -r .appId)
SP_PASSWORD=$(echo $SP_OUTPUT | jq -r .password)
echo "Service Principal App ID: $SP_APP_ID"
echo $SP_PASSWORD > sp_password.txt

# Store Credentials in Key Vault
echo "Storing credentials in Key Vault..."
az keyvault create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $KEY_VAULT_NAME \
  --location $LOCATION \
  --enable-rbac-authorization true
check_error "Failed to create Key Vault"

# Assign Key Vault Secrets Officer role to current user
echo "Assigning Key Vault Secrets Officer role to current user..."
CURRENT_USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)
az role assignment create \
  --role "Key Vault Secrets Officer" \
  --assignee $CURRENT_USER_OBJECT_ID \
  --scope "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME"
check_error "Failed to assign Key Vault Secrets Officer role"

# Wait for RBAC propagation
echo "Waiting 60 seconds for RBAC role assignment to propagate..."
sleep 60

# Set the service principal password in Key Vault with retry
echo "Setting service principal password in Key Vault..."
for i in {1..3}; do
  az keyvault secret set \
    --vault-name $KEY_VAULT_NAME \
    --name "TerraformSPPassword" \
    --value "$(cat sp_password.txt)" && break
  echo "Attempt $i failed. Retrying in 30 seconds..."
  sleep 30
done
check_error "Failed to store credentials in Key Vault"
rm sp_password.txt

# Grant Service Principal access to Key Vault secrets
echo "Granting service principal access to Key Vault..."
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee $SP_APP_ID \
  --scope "/subscriptions/$MY_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME"
check_error "Failed to set Key Vault policy"



# # Configure Blob Replication
# echo "Configuring blob replication for disaster recovery..."
# # Create a replication policy
# az storage account or-policy create \
#   --account-name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --source-account $STORAGE_ACCOUNT_NAME \
#   --destination-account $MY_STORAGE_ACCOUNT_BACKUP \
#   --source-container $CONTAINER_NAME \
#   --destination-container $CONTAINER_NAME \
#   --policy-name "tfstate-replication"
# check_error "Failed to create object replication policy"


# # Configure Blob Replication
# echo "Configuring blob replication for disaster recovery..."
# az storage account or-policy create \
#   --account-name $STORAGE_ACCOUNT_NAME \
#   --resource-group $RESOURCE_GROUP_NAME \
#   --source-account $STORAGE_ACCOUNT_NAME \
#   --destination-account $MY_STORAGE_ACCOUNT_BACKUP \
#   --source-container $CONTAINER_NAME \
#   --destination-container $CONTAINER_NAME \
#   --rule-name "tfstate-replication-rule"
# check_error "Failed to create object replication policy"


# Output Environment Variables
log "Environment variables for Terraform:"
log "export ARM_CLIENT_ID=$SP_APP_ID"
log "export ARM_CLIENT_SECRET=\$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name TerraformSPPassword --query value -o tsv)"
log "export ARM_SUBSCRIPTION_ID=$MY_SUBSCRIPTION_ID"
log "export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)"
log "export ARM_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT_NAME"
log "Run these commands before executing 'terraform init'."