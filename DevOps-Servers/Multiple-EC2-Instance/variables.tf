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
 description = "Security Group for VPROFILE Load Balancer"
 default     = "V-PROVILE-APP"
}

variable "environment-ELB-SG" {
 description = "Security Group for VPROFILE Load Balancer"
 default     = "V-PROVILE-ELB-SG"
}

variable "environment-BACKEND-SERVICES-SG" {
 description = "Security Group for VPROFILE-BACKEND-SERVICES Load Balancer"
 default     = "V-PROVILE-BACKEND-SERVICES-SG"
}

variable "environment-TOMCAT-APPLICATION-SG" {
 description = "Security Group for VPROFILE-APPLICATION  Load Balancer"
 default     = "V-PROVILE-TOMCAT-APPLICATION-SG"
}

variable "environment1" {
  description = "App Server"
 default     =   "App-Server"
}
variable "environment2" {
  description = "Database Server"
 default     = "DB Server"
}
variable "environment3" {
  description = "Memcache Server"
 default     = "Memcache-Server"
}
variable "environment4" {
  description = "Rabbit MQ erver"
 default     = "Rabbit-MQ-Server"
}
# variable "environment5" {
#   description = "Web Server"
#  default     = "Web-Server"
# }
