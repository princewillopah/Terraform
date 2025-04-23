output "bucket_names" {
  description = "List of S3 bucket names"
  value = [for i in range(var.bucket_count) : aws_s3_bucket.bucket[i].bucket]
}
output "common_name_of_s3_buckets_created" {
  description = "List of S3 bucket names"
   value = var.bucket_prefix
}

output "number_of_s3_buckets_created" {
 value = var.bucket_count
}

output "bucket_urls" {
  description = "List of S3 bucket URLs"
  value = [for i in range(var.bucket_count) : "https://${aws_s3_bucket.bucket[i].bucket}.s3.${var.aws_region}.amazonaws.com"]
}