

# # Define a variable for private subnet CIDR ranges, which also allows for custom values or uses defaults.
# variable "private_subnet_cidrs" {
#   type        = list(string)
#   description = "Private Subnet CIDR values"
#   default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
# }

# # Define a variable for public subnet CIDR ranges, which allows for custom values or uses defaults.
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "avail_zone" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "environment" {
  description = "Environment Name"
  default     = "Testing-Server"
}

variable "blocked_ip" {
  description = "The IP address to block"
  type        = string
  default     = "102.89.33.126/32" # Replace with your laptop's IP address
}
# variable "environment1" {
#   description = "Jenkin Master"
#  default     = "Jenkin Master"
# }
# variable "environment2" {
#   description = "Jenkin Slave1"
#  default     = "Jenkin-Slave1"
# }
# variable "environment3" {
#   description = "Ansible Server"
#  default     = "Ansible-Server"
# }
