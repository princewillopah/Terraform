variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for Terraform state"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of DynamoDB table for Terraform state locking"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, stage, prod)"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags"
  default     = {}
}
