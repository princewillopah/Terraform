variable "aws_region" {
  description = "The AWS region to deploy into."
  default     = "eu-north-1"
}
variable "environment" {
  description = "Environment name (e.g., dev, prod)."
  default     = "dev"
}

variable "key_name" {
   description="main ssh key"
   default="main-ssh-key" # Replace with a valid AMI ID.
}
# variable "vpc_cidr" {
#   description = "The CIDR block for the VPC."
#   default     = "10.0.0.0/16"
# }

# variable "public_subnet_cidr" {
#   description = "The CIDR block for the public subnet."
#   default     = "10.0.1.0/24"
# }

# variable "private_subnet_cidr" {
#   description = "The CIDR block for the private subnet."
#   default     = "10.0.2.0/24"
# }

# variable "public_ami" { 
#    description="AMI ID for public instances."
# }
# variable "private_ami" { 
#    description="AMI ID for public instances."
# }