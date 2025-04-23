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