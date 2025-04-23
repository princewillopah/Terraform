# variable "vpc_a_id" {}
# variable "vpc_b_id" {}
# variable "vpc_c_id" {}

# variable "vpc_A_subnet_ids" {}
# variable "vpc_B_subnet_ids" {}
# variable "vpc_C_subnet_ids" {}



variable "vpc_a_id" {
  description = "ID of VPC-A"
}

variable "vpc_b_id" {
  description = "ID of VPC-B"
}

variable "vpc_c_id" {
  description = "ID of VPC-C"
}

variable "vpc_A_subnet_ids" {
  description = "List of subnet IDs for VPC-A"
  type        = list(string)
}

variable "vpc_B_subnet_ids" {
  description = "List of subnet IDs for VPC-B"
  type        = list(string)
}

variable "vpc_C_subnet_ids" {
  description = "List of subnet IDs for VPC-C"
  type        = list(string)
}

variable "vpc_A_private_rt" {}
variable "vpc_B_private_rt" {}
variable "vpc_C_private_rt" {}

variable "vpc_A_cidr_block" {}
variable "vpc_B_cidr_block" {}
variable "vpc_C_cidr_block" {}