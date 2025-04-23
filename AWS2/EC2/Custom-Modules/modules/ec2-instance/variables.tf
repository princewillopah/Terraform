variable "ami" {
  description = "The ID of the AMI to use for the instance"
  type        = string
  default     ="ami-0914547665e6a707c"
}

variable "instance_type" {
  description = "The type of instance to launch"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the key pair to use"
  type        = string
  default     = "Prince-Affy-Main-SSHKEY"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "Default Linux Server"
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
  default     = aws_security_group.ec2-security-group.id
}

variable "volume_size" {
  description = "The size of the volume in gigabytes"
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "The type of volume (e.g., gp2, io1)"
  type        = string
  default     = "gp2"
}

# variable "subnet_id" {
#   description = "The subnet ID to launch the instance in"
#   type        = string
#   default     = 
# }

variable "region" {
  description = "AWS region to deploy the instance"
  type        = string
  default     = "eu-north-1"
}
