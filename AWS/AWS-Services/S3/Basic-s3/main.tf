resource "aws_s3_bucket" "example" {
  bucket = "my-first-s3-bucket-xxx"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}