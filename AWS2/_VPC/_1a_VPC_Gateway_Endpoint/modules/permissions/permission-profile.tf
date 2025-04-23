resource "aws_iam_instance_profile" "s3_access_instance_profile" {
  name = "S3AccessInstanceProfile"
  role = aws_iam_role.s3_access_role.name
}