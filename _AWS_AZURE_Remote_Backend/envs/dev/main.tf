module "remote_backend" {
  source              = "../../modules/backend"
  bucket_name         = "${var.org}-${var.environment}-tf-state"
  dynamodb_table_name = "${var.org}-${var.environment}-tf-locks"
  environment         = var.environment

  tags = {
    Project     = "Terraform Backend"
    ManagedBy   = "Terraform"
    Environment = var.environment
  }
}

variable "org" {
  type        = string
  description = "Organisation name or prefix"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, stage, prod)"
}
