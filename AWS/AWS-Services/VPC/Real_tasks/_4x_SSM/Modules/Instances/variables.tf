
# variable "app_name" {} 
# variable "app_vpc_id" {}

# variable "ami_id" {}
# variable "instance_type" {}

# variable "public_subnets" {type = map(string)} // values from terraform.tfvars
# variable "private_app_subnets" {type = map(string)} // values from terraform.tfvars
# variable "private_data_subnets" {type = map(string)} // values from terraform.tfvars

variable "role_name" {}
variable "app_name" {}
variable "env" {}

variable "ami_id" {}
variable "instance_type" {}

variable "key_name" {
  type    = string
  default = null
}

variable "associate_public_ip" {
  type    = bool
  default = false
}

variable "subnet_map" {
  type = map(object({
    subnet_id = string
  }))
}

variable "security_group_ids" {
  type = list(string)
}

variable "iam_instance_profile" {}
