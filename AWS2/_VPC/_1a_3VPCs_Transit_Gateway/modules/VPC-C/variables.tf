variable "vpc_cidr" {
   description = "The CIDR block for the VPC 2."
   default     = "10.3.0.0/16"
}

variable "private_subnet_cidr"{ 
description="CIDR block for the private subnet."
 default     = "10.3.1.0/24"
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


variable "environment" {}
variable "key_name" {}


