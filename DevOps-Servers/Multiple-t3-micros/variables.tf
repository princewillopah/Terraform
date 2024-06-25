# # Define a variable for public subnet CIDR ranges, which allows for custom values or uses defaults.
# variable "public_subnet_cidrs" {
#   type        = list(string)
#   description = "Public Subnet CIDR values"
#   default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
# }

# # Define a variable for private subnet CIDR ranges, which also allows for custom values or uses defaults.
# variable "private_subnet_cidrs" {
#   type        = list(string)
#   description = "Private Subnet CIDR values"
#   default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
# }

variable "avail_zone" {
 description = "Availability Zones"
 default     = "eu-north-1"
}

variable "environment" {
  description = "EKS-Bootstrap-Server"
 default     = "EKS-Bootstrap-Server"
}

variable "instances" {
  description = "List of instances to create"
  type = list(object({
    name          = string
    ami           = string
    instance_type = string
    key_name      = string
  }))
  default = [
    {
      name          = "Server-1"
      ami           = "ami-0914547665e6a707c"
      instance_type = "t3.micro"
      key_name      = "temporal-ekc-bootstrap-server-sshkey"
    },
    {
      name          = "Server-2"
      ami           = "ami-0914547665e6a707c"
      instance_type = "t3.micro"
      key_name      = "temporal-ekc-bootstrap-server-sshkey"
    }
    # {
    #   name          = "EKS-Bootstrap-Server-3"
    #   ami           = "ami-0914547665e6a707c"
    #   instance_type = "t3.micro"
    #   key_name      = "temporal-ekc-bootstrap-server-sshkey"
    # }
    // Add more instances as needed
  ]
}
