variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_security_group_ids" {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}