variable "aws_region" {
   description = "The AWS region to deploy into."
   default     = "eu-north-1"
}

variable "vpc_cidr" {
   description = "The CIDR block for the VPC."
   default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
   description = "The CIDR block for the public subnet."
   default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
   description = "The CIDR block for the private subnet."
   default     = "10.0.2.0/24"
}

variable "public_subnet_az" {
   description="Availability zone for public subnet."
   default="eu-north-1a"
}

variable "private_subnet_az" {
   description="Availability zone for private subnet."
   default="eu-north-1a"
}

variable "environment" {
   description="Environment name (e.g., dev, prod)."
   default="dev"
}

variable "instance_type" {
   description="EC2 instance type."
   default="t3.micro"
}

variable "public_ami" {
   description="AMI ID for public instances."
   default="ami-0914547665e6a707c" # Replace with a valid AMI ID.
}

variable "private_ami" {
   description="AMI ID for private instances."
   default="ami-0914547665e6a707c" # Replace with a valid AMI ID.
}
variable "key_name" {
   description="main ssh key"
   default="main-ssh-key" # Replace with a valid AMI ID.
}
