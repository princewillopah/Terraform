variable "private_subnet_cidr"{ 
description="CIDR block for the private subnet."
 default     = "10.0.2.0/24"
}
variable "instance_type"{ 
description="EC2 instance type."
default="t3.micro"
}
variable "private_ami"{ 
   description="AMI ID for public instances."
    default="ami-0914547665e6a707c"
}
variable "key_name"{ }
variable "environment"{}
variable "vpc_id"{}
# variable "s3_access_instance_profile_name" {}