variable "app_name" {}
variable "vpc_id" {}

variable "public_subnet_ids" {
  type = list(string)
  default = [ "subnet-033b1d539e962bfc3", "subnet-01fe2c109e55cfcf0"]
  }




# EC2 Instance launch template variables
variable "instance_type" {}
variable "ami_id" {}
variable "my_ip" {}
variable "key_name" {}

# auto scaling group sizes
variable "desired_capacity" { default = 2 }
variable "min_size" { default = 2 }
variable "max_size" { default = 4 }
variable "private_subnet_ids" { type = list(string) }



# variable "alb_target_group_arn" {}
# variable "alb_arn_suffix" { description = "ALB ARN suffix (owner/{loadbalancername}/{id}) used for target tracking resource_label" }
# variable "alb_target_group_name" {}
# variable "alb_security_group_id" {}
# variable "ami_id" {}
# variable "instance_type" { default = "t3.micro" }




variable "requests_per_target" { default = 50 }
