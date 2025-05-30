variable "vpc_cidr" {
   description = "The CIDR block for the Provider VPC ."
   default     = "11.0.0.0/16"
}
variable "public_subnet_cidr" {
   description="CIDR block for the public subnet."
   default     = "11.0.1.0/24"
}

variable "private_subnet_cidr"{ 
description="CIDR block for the private subnet."
 default     = "11.0.2.0/24"
}
variable "instance_type" { 
   description="EC2 instance type."
   default="t3.micro"
}
variable "ec2_ami" { 
   description="AMI ID for public instances."
    default="ami-0914547665e6a707c"
}
# =======================================


variable "environment" { default  = "Provider"}
variable "key_name" {}
variable "ssm_instance_profile" {}

