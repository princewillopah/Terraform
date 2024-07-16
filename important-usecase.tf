//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
# Count function
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


# ---------------------------------------------------------------------------------------------------------------------------------------
# This configuration will create 4 storage accounts with name Storage-Account-1, Storage-Account-2, Storage-Account-3, Storage-Account-4
# ---------------------------------------------------------------------------------------------------------------------------------------

# resource "azurerm_storage_account" "my-storage-account" {
# count = 4
#   name                     = "Storage-Account-${count.index + 1}"
#   resource_group_name      = data.azurerm_resource_group.my-RG.name
#   location                 = data.azurerm_resource_group.my-RG.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   account_kind = "StorageV2"  #optional
 
# }
# ---------------------------------------------------------------------------------------------------------------------------------------
# This configuration will produce 3 subnets based on the lenth of the variable "subnet_cidr_blocks"
# ---------------------------------------------------------------------------------------------------------------------------------------

# variable "subnet_cidr_blocks" {
#   default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# }
# # resource "azurerm_virtual_network" "example" {
# # ---
# # }

# resource "azurerm_subnet" "example" {
#   count                   = length(var.subnet_cidr_blocks)
#   name                    = "subnet-${count.index + 1}"
#   resource_group_name     = azurerm_resource_group.example.name
#   virtual_network_name    = azurerm_virtual_network.example.name
#   address_prefix          = var.subnet_cidr_blocks[count.index]  // first loop will 
# }
# ----------- The Equivalent subnets will be ----
# resource "azurerm_subnet" "example" {
#   name                    = "subnet-1"
#   resource_group_name     = azurerm_resource_group.example.name
#   virtual_network_name    = azurerm_virtual_network.example.name
#   address_prefix          = var.subnet_cidr_blocks[0]  // in first loop will address_prefix  = "10.0.1.0/24"
# }
# resource "azurerm_subnet" "example" {
#   name                    = "subnet-2"
#   resource_group_name     = azurerm_resource_group.example.name
#   virtual_network_name    = azurerm_virtual_network.example.name
#   address_prefix          = var.subnet_cidr_blocks[1]  // in first loop will , address_prefix  = "10.0.2.0/24",
# }
# resource "azurerm_subnet" "example" {
#   name                    = "subnet-3"
#   resource_group_name     = azurerm_resource_group.example.name
#   virtual_network_name    = azurerm_virtual_network.example.name
#   address_prefix          = var.subnet_cidr_blocks[2]  // in first loop will address_prefix  = "10.0.3.0/24"
# }



# ---------------------------------------------------------------------------------------------------------------------------------------
# This configuration will produce 3 subnets based on the lenth of the variable "subnet_cidr_blocks"
# ---------------------------------------------------------------------------------------------------------------------------------------
# locals {
#   my_resource_group_name    = "Prince-RG"
#   my_resource_group_location = "eastus"
  
#   subnets = [
#     {
#       name           = "subnet1"
#       my-address_prefix = "10.0.1.0/24"
#       security_group = azurerm_network_security_group.security-group.id
#     },
#     {
#       name           = "subnet2"
#       my-address_prefix = "10.0.2.0/24"
#     }
#   ]
# }

# resource "azurerm_subnet" "subnets" {
#   count               = length(local.subnets)
#   name                = local.subnets[count.index].name
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes    = [local.subnets[count.index].my-address_prefix]
#   # network_security_group_id = local.subnets[count.index].security_group != null ? local.subnets[count.index].security_group : null
# }
# ----- The Equivalent subnets will be ----

# resource "azurerm_subnet" "subnets" {
#   name                = local.subnets[0].name  // name = subnet1
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes    = [local.subnets[0].my-address_prefix]  //  address_prefixes = "10.0.0.0/24"
#   # network_security_group_id = local.subnets[0].security_group != null ? local.subnets[0].security_group : null
# }

# resource "azurerm_subnet" "subnets" {
#   name                = local.subnets[1].name   //  name = subnet2
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes    = [local.subnets[1].my-address_prefix]   //  address_prefixes = "10.0.1.0/24"
#   # network_security_group_id = local.subnets[1].security_group != null ? local.subnets[1].security_group : null
# }
# -------------------------------------------------------------------------------------------------
# # Define a variable for public subnet CIDR ranges, which allows for custom values or uses defaults.
# variable "public_subnet_cidrs" {
#   type        = list(string)
#   description = "Public Subnet CIDR values"
#   default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# }

# # Define a variable for private subnet CIDR ranges, which also allows for custom values or uses defaults.
# variable "private_subnet_cidrs" {
#   type        = list(string)
#   description = "Private Subnet CIDR values"
#   default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
# }

# variable "azs" {
#  type        = list(string)
#  description = "Availability Zones"
#  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
# }

# # -- Create public subnets within the AWS VPC using the "aws_subnet" resource.
# resource "aws_subnet" "public_subnets" {
#   count      = length(var.public_subnet_cidrs)  # Create one subnet per value in public_subnet_cidrs
#   vpc_id     = aws_vpc.main.id                   # Associate these subnets with an existing VPC
#   cidr_block = element(var.public_subnet_cidrs, count.index)  # Use the CIDR block from the variable list
#   availability_zone = element(var.azs, count.index)
#   tags = {
#     Name = "Public Subnet ${count.index + 1}"  # Name each subnet uniquely based on its index
#   }
# }

# # ----Create private subnets within the AWS VPC using the "aws_subnet" resource.
# resource "aws_subnet" "private_subnets" {
#   count      = length(var.private_subnet_cidrs)  # Create one subnet per value in private_subnet_cidrs
#   vpc_id     = aws_vpc.main.id                   # Associate these subnets with an existing VPC
#   cidr_block = element(var.private_subnet_cidrs, count.index)  # Use the CIDR block from the variable list
#   availability_zone = element(var.azs, count.index) # specify the zone for this subnet
#   tags = {
#     Name = "Private Subnet ${count.index + 1}"  # Name each subnet uniquely based on its index
#   }
# }

# ---------------------------------------------------------------------------------------------------------------------------------------
# This configuration will produce any number of  subnets(less than 8) based on input 
# ---------------------------------------------------------------------------------------------------------------------------------------
# Define a variable for public subnet CIDR ranges, which allows for custom values or uses defaults.
variable "number_public_subnet" {
  type        = number
  description = "Number of Public Subnets "
  default     = 4
  validation {
    condition = var.number_public_subnet < 5
    error_message = "The number of subnets must be less than 5."
  }
}


resource "azurerm_subnet" "my---subnets" {
  count                   = var.number_public_subnet  // number from variable 
  name                    = "subnet-${count.index + 1}"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.my-vnet.name
  address_prefixes          = ["10.0.${count.index}.0/24"]  // ["10.0.0.0/24"],["10.0.0.0/24"],["10.0.3.0/24"],["10.0.3.0/24"]  ...  
 
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  FOR_EACH
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* 
 The for_each meta-argument accepts a map or a set of strings
for_each needs a data type of set. this if you are given a set of strings, this 
is straight forward. if the variable is a list, it needs to be convested to a set
*/ 
# resource "azurerm_resource_group" "rg" {
#   for_each = tomap({
#     a_group       = "eastus"
#     another_group = "westus2"
#   })
#   name     = each.key
#   location = each.value
# }
# resource "aws_iam_user" "the-accounts" {
#   for_each = toset(["Todd", "James", "Alice", "Dottie"])
#   name     = each.key
# #   name     = "${each.key}_bucket"  Todd_bucket  James_bucket  Alice_bucket Dottie_bucket
# }

# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////