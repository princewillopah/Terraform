module "s3" {
  source            = "./Modules/S3"
  bucket_name       = "${var.bucket_name}-${terraform.workspace}"  # Append workspace to bucket name
  versioning_enabled = var.versioning_enabled
  environment       = terraform.workspace
}

# Appending terraform.workspace to 
# bucket_name ensures unique bucket names (e.g., my-bucket-dev, my-bucket-prod).