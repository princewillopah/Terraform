
# -------------------------------------------------
# Shared Variables File
# ---------------------------------------------------
variable "app_name" {}
variable "instance_type" {}
variable "ami_id" {}
variable "key_name" {}
variable "domain_name" {}

# -------------------------------------------------
# Variables for VPC Module
# ---------------------------------------------------
variable "vpc_cidr_block" {} // values from terraform.tfvars







variable "private_app_subnets_vars" {
  type = map(object({
    az          = string
    cidr_index  = number
  }))
}



