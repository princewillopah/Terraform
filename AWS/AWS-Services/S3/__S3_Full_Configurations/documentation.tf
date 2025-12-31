# ---------------------------
# S3 BUCKET
# ---------------------------
resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-name-12345" # Required: Globally unique DNS-compliant name
  tags = {
    Environment = "prod"
    Owner       = "team-xyz"
  }
}


# -----------------------------------------------------------
# OWNERSHIP CONTROLS (Required in some regions/uses)
# -----------------------------------------------------------
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerEnforced" # Default if unspecified in new buckets (as of 2021+), but must be EXPLICIT in Terraform
    # Options: 
    #   "BucketOwnerPreferred", "ObjectWriter", "BucketOwnerEnforced"
    # "BucketOwnerEnforced" = disables ACLs (recommended for most use cases)
  }
}

# ------------------------- --------------------------------------------------------
# PUBLIC ACCESS BLOCK (Highly Recommended - CRITICAL FOR SECURITY)
# ----------------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true  # Default in console, but NOT in Terraform → must set
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Default AWS behavior:
    # ❌ NOT enabled automatically
    # You must define this explicitly to prevent accidental exposure.


# -------------------------------------------------------------------
# Bucket Policy (IAM-Based Access Control)
# -------------------------------------------------------------------
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowEC2Access"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:role/my-ec2-role"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.example.arn}",
          "${aws_s3_bucket.example.arn}/*"
        ]
      }
    ]
  })
}
# Note: Adjust the Principal and Actions as per your requirements.
# This example allows a specific EC2 role to Get and Put objects in the bucket.

# ---------------------------
# SERVER-SIDE ENCRYPTION (SSE)
# ---------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # or "aws:kms" (then specify kms_master_key_id)
      # kms_master_key_id = aws_kms_key.mykey.arn # if using KMS
    }
    bucket_key_enabled = false # Only for KMS; enables S3 Bucket Keys (reduces KMS costs)
  }
}
# Note: SSE is critical for data protection. Choose the appropriate algorithm based on your security requirements.
# AES256 uses Amazon S3-managed keys.
# aws:kms allows using customer-managed keys for more control.

# ------------------------------------------------------------
# LIFECYCLE RULES (Optional - For Data Management)(Cost Optimization)
# ------------------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.example.id 
    rule {
        id     = "TransitionToIA"
        status = "Enabled"
    
        transition {
            days          = 30
            storage_class = "STANDARD_IA" # Infrequent Access
        }
        transition {
            days          = 90
            storage_class = "GLACIER"
        }
        expiration {
        days = 365
        }

        noncurrent_version_expiration {
      noncurrent_days = 90
      }
    }


}
# Note: Lifecycle rules help manage storage costs by transitioning objects to cheaper storage classes or expiring them after a set period.
# Adjust the days and storage_class as per your data retention policies.

# Common storage classes:
#     STANDARD
#     STANDARD_IA
#     ONEZONE_IA
#     GLACIER
#     DEEP_ARCHIVE

# -----------------------------------------------
# VERSIONING (Recommended for Data Protection)
# -----------------------------------------------

resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
    versioning_configuration {
        status = "Enabled" # Options: "Enabled", "Suspended"
    }
}
# Note: Enabling versioning helps protect against accidental deletions or overwrites of objects.
# It is a best practice to enable versioning on production buckets.
# Default: Suspended

# -----------------------------------------------
# LOGGING (Optional - For Access Auditing)
# -----------------------------------------------

# You need a separate bucket for logs (with proper ACLs)
resource "aws_s3_bucket" "logging" {  # this is a new bucket for logging
  bucket = "my-logs-bucket-12345"
}


resource "aws_s3_bucket_acl" "logging_acl" {
  bucket = aws_s3_bucket.logging.id
  acl    = "log-delivery-write" # Required for S3 logging
}

resource "aws_s3_bucket_logging" "example" {
  bucket = aws_s3_bucket.example.id
  target_bucket = aws_s3_bucket.logging.id
  target_prefix = "example-bucket-logs/"
}

# resource "aws_s3_bucket" "logging" {
#   bucket = "my-logs-bucket-12345"
# …  target_prefix = "example-bucket-logs/"
# }


# resource "aws_s3_bucket_logging" "example" {
#     bucket = aws_s3_bucket.example.id   
#     target_bucket = aws_s3_bucket.log_bucket.id  # Bucket to store logs. Ensure this bucket exists. # you can create a separate bucket for logs or use the same bucket.
#     target_prefix = "log/"
# }
# Note: Logging provides insights into access patterns and can help with security audits.
# Ensure that the target bucket for logs has the appropriate permissions to receive log files.
# You may need to create a separate S3 bucket (e.g., aws_s3_bucket.log_bucket) for storing logs.
# ---------------------------
# TAGS (Recommended for Resource Management)
# ---------------------------
resource "aws_s3_bucket_tagging" "example" {
    bucket = aws_s3_bucket.example.id
    tag_set = {
        Environment = "prod"
        Owner       = "team-xyz"
    }
}
# Note: Tags help in organizing and managing AWS resources.
# They are useful for cost allocation, automation, and access control.
# ---------------------------
# NOTIFICATION CONFIGURATION (Optional - For Event-Driven Architectures)
# ---------------------------
resource "aws_s3_bucket_notification" "example" {
    bucket = aws_s3_bucket.example.id
    lambda_function {
        lambda_function_arn = aws_lambda_function.my_lambda.arn
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "images/"
        filter_suffix       = ".jpg"
    }
}
# Note: Notifications can trigger AWS Lambda functions, SNS topics, or SQS queues based on S3 events.
# This is useful for building event-driven applications.
# Ensure that the necessary permissions are set for the notification targets.
# ---------------------------
# CORS CONFIGURATION (Optional - For Cross-Origin Access)
# ---------------------------
resource "aws_s3_bucket_cors_configuration" "example" {
    bucket = aws_s3_bucket.example.id
    cors_rule {
        allowed_headers = ["*"]
        allowed_methods = ["GET", "PUT", "POST"]
        allowed_origins = ["https://example.com"]
        expose_headers  = ["ETag"]
        max_age_seconds = 3000
    }
}
# Note: CORS configuration allows you to specify how your S3 bucket can be accessed from different origins.
# Adjust the allowed methods and origins based on your application's requirements.  
# ---------------------------
# REPLICATION CONFIGURATION (Optional - For Data Redundancy)
# ---------------------------
resource "aws_s3_bucket_replication_configuration" "example" {
    bucket = aws_s3_bucket.example.id
    role   = aws_iam_role.s3_replication_role.arn   
    rule {
        id     = "ReplicateToAnotherRegion"
        status = "Enabled"
        destination {
            bucket        = aws_s3_bucket.destination_bucket.arn
            storage_class = "STANDARD_IA"
        }
        filter {
            prefix = "logs/"
        }
    }
}
# Note: Replication helps in maintaining copies of your data across different AWS regions for disaster recovery and compliance.
# Ensure that the IAM role specified has the necessary permissions for replication. 
# ------------------------------------------------------
# METRICS CONFIGURATION (Optional - For Monitoring)
# ------------------------------------------------------
resource "aws_s3_bucket_metric" "example" {
    bucket = aws_s3_bucket.example.id
    name   = "EntireBucketMetric"
    filter {
        prefix = ""
    }
}
# Note: Metrics provide insights into the usage and performance of your S3 bucket.
# You can monitor these metrics using Amazon CloudWatch.

# ------------------------------------------------------
# Static Website Hosting (Optional)
# ------------------------------------------------------
resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.example.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
# ------------------------------------------------------
# Object Lock (Compliance / WORM)
# ------------------------------------------------------
resource "aws_s3_bucket_object_lock_configuration" "this" {
  bucket = aws_s3_bucket.example.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 30
    }
  }
}
#⚠️ Requires bucket to be created with Object Lock enabled at creation time








































































































































