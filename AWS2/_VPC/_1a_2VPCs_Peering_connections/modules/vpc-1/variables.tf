variable "vpc_cidr" {
   description = "The CIDR block for the VPC 1."
   default     = "10.1.0.0/16"
}
variable "public_subnet_cidr" {
   description="CIDR block for the public subnet."
   default     = "10.1.1.0/24"
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

variable "private_subnet_cidr"{ 
description="CIDR block for the private subnet."
 default     = "10.1.2.0/24"
}


variable "environment" {}
variable "key_name" {}




