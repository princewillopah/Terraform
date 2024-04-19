variable "number_public_subnet" {
  type = number
  description = "Number of Public Subnets "
  default     = 4
  validation {
    condition = var.number_public_subnet < 5
    error_message = "The number of subnets must be less than 5."
  }
}
