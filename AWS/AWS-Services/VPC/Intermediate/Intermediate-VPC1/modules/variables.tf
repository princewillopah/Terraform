
variable "name" {
  type        = string
  description = "Name prefix for all resources"
}

variable "cidr" {
  type        = string
  description = "Main VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones to use"
}

variable "create_nat_per_az" {
  type        = bool
  description = "If true, create NAT Gateway per AZ (recommended for production)"
  default     = true
}

variable "public_subnet_bits" {
  type    = number
  default = 24
}

variable "app_subnet_bits" {
  type    = number
  default = 24
}

variable "data_subnet_bits" {
  type    = number
  default = 24
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default     = {}
}
