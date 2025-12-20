
variable "app_name" {} 
variable "app_vpc_id" {}

variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
# variable "public_subnet_az1" {}
# variable "iam_instance_profile" {}




variable "private_subnet_ids" {
  type = list(string)
}

# variable "security_group_id" {}

variable "iam_instance_profile_name" {}

variable "desired_capacity" {}
variable "min_size" {}
variable "max_size" {}

variable "target_group_arn" {}



variable "alb_sg_id" {
  description = "ALB security group ID"
}

variable "jump_sg_id" {
  description = "Jump host security group ID for SSH access"
}  

variable "app_port" {
  default = 80
}