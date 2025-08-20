variable "bucket_name" {
  description = "Base name for the S3 bucket (workspace will be appended)"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}