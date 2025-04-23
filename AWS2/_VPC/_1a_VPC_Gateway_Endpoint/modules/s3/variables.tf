variable "aws_region" {
  description = "The AWS region to deploy into."
  default     = "eu-north-1"
}

variable "bucket_count" {
  description = "Number of S3 buckets to create."
  default     = 3
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket names."
  default     = "-s3-bucket"
}

# variable "environment" {
#   description = "Environment name (e.g., dev, prod)."
#   default     = "dev"
# }
variable "environment" {}

