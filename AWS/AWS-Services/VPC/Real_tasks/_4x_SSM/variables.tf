
# -------------------------------------------------
# Shared Variables File
# ---------------------------------------------------
variable "app_name" {}

variable "vpc_cidr_block" {} // values from terraform.tfvars
variable "public_subnets" {type = map(string)} // values from terraform.tfvars
variable "private_app_subnets" {type = map(string)} // values from terraform.tfvars
variable "private_data_subnets" {type = map(string)} // values from terraform.tfvars



variable "env" {}

variable "app_ami" {}
variable "app_instance_type" {}

variable "app_key_name" {
  type    = string
  default = null
}

variable "app_instances" {
  description = "Map of app instances"
  type = map(object({
    subnet_id = string
  }))
}




# # variables.tf
# variable "subnets" {
#   description = "List of subnet configurations"
#   type = list(object({
#     cidr_block  = string
#     availability_zone = string
#     subnet_type = string  # e.g., "public", "private"
#   }))
# }

 # default = {
  #   us-east-1a = "10.5.1.0/24"
  #   us-east-1b = "10.5.4.0/24"
  # }

# variable "private_app_subnets_vars" {
#   type = map(object({
#     az          = string
#     cidr_index  = number
#   }))
# }



