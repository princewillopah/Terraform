variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  description = "AWS named profile (optional)"
  default     = null
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "org" {
  type        = string
  description = "Short org or project prefix"
}

variable "cost_center" {
  type        = string
  description = "Cost center tag"
  default     = null
}