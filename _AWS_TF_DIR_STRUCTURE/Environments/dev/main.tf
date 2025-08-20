module "s3" {
  source            = "../../Modules/S3"
  bucket_name       = var.bucket_name
  versioning_enabled = var.versioning_enabled
  environment       = "dev"
}