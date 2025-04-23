output "bucket_names" {
  description = "List of S3 bucket names"
  value =  aws_s3_bucket.my_bucket.bucket
}
output "common_name_of_s3_buckets_created" {
  description = "List of S3 bucket names"
   value = var.bucket_prefix
}

output "bucket_urls" {
  value = "https://${aws_s3_bucket.my_bucket.bucket}.s3.${var.aws_region}.amazonaws.com"
}