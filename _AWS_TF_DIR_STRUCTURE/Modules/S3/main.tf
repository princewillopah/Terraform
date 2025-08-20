resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  acl    = "private"  # Production standard: private by default for security

  versioning {
    enabled = var.versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"  # Enforce encryption for prod
      }
    }
  }

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}