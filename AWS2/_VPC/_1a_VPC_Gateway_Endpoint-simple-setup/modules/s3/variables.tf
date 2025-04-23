# variable "aws_region" {
#   description = "The AWS region to deploy into."
#   default     = "eu-north-1"
# }



variable "bucket_prefix" {
  description = "Prefix for S3 bucket names."
  default     = "s3-bucket"
}


variable "environment" {}
variable "aws_region" {}
variable "my-s3_vpc_endpoint" {}
