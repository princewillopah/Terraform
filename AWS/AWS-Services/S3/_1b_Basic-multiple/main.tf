
provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}




resource "aws_s3_bucket" "bucket" {
  count = var.bucket_count

  bucket = "princewill-${var.bucket_prefix}-${count.index + 1}"
#   acl    = "private"

  tags = {
    Name        = "my${var.bucket_prefix}-${count.index + 1}"
    Environment = var.environment
  }
}
#==============================================================


# # Create S3 Bucket for Bucket 1
# resource "aws_s3_bucket" "bucket_1" {
#   bucket = "princewill--s3-bucket-1"  # Ensure this name is globally unique

#   tags = {
#     Name = "my-s3-bucket-1"
#   }
# }

# # Create S3 Bucket for Bucket 2
# resource "aws_s3_bucket" "bucket_2" {
#   bucket = "princewill--s3-bucket-2"  # Ensure this name is globally unique

#   tags = {
#     Name = "my-s3-bucket-2"
#   }
# }

# # Create S3 Bucket for Bucket 3
# resource "aws_s3_bucket" "bucket_3" {
#   bucket = "princewill--s3-bucket-3"  # Ensure this name is globally unique

#   tags = {
#     Name = "my-s3-bucket-3"
#   }
# }


#==============================================================
# acl = access control list (ACL)
# private: Only the bucket owner has access.
# public-read: Anyone can read objects in the bucket.
# public-read-write: Anyone can read and write objects in the bucket (not recommended).