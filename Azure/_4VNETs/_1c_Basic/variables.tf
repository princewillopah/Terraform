variable "number_subnets" {
  type        = number
  description = "Total number of subnets (both public and private)"
  default     = 6
  validation {
    condition     = var.number_subnets % 2 == 0 && var.number_subnets >= 2
    error_message = "The number of subnets must be an even number greater than or equal to 2."
  }
}