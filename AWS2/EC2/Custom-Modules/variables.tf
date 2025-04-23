variable "ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-12345678"  # Replace with the actual AMI ID
}

variable "instance_type" {
  description = "The instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "example-instance"
}

variable "security_group_ids" {
  description = "Security group IDs for the instance"
  type        = list(string)
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance"
  type        = string
}

variable "volume_size" {
  description = "Size of the EBS volume"
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "Type of EBS volume"
  type        = string
  default     = "gp2"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}
