output "s3_access_instance_profile_name" {
  description = "The name of the IAM instance profile for S3 access"
  value       = aws_iam_instance_profile.s3_access_instance_profile.name
}
