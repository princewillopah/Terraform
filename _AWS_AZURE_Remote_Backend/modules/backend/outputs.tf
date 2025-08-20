output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "The name of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.this.name
  description = "The name of the DynamoDB table"
}
