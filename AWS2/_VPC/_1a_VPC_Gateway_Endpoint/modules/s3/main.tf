resource "aws_s3_bucket" "bucket" {
  count = var.bucket_count

  bucket = "princewill-${var.bucket_prefix}-${count.index + 1}"
#   acl    = "private"

  tags = {
    Name        = "my${var.bucket_prefix}-${count.index + 1}"
    Environment = var.environment
  }
}

