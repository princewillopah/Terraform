output "s3_bucket_arn" {
  description = "ARN of the dev S3 bucket"
  value       = module.s3.bucket_arn
}

output "s3_bucket_name" {
  description = "Name of the dev S3 bucket"
  value       = module.s3.bucket_name
}