resource "aws_s3_bucket" "my_bucket" {
  bucket = "princewill-${var.bucket_prefix}-xxx"  # Ensure this bucket name is unique

  tags = {
    Name        = "my${var.bucket_prefix}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = var.my-s3_vpc_endpoint
          }
        }
      }
    ]
  })
}


# resource "aws_s3_bucket_public_access_block" "example" {
#   bucket = aws_s3_bucket.my_bucket.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_bucket_policy" "my_bucket_policy" {
#   depends_on = [aws_s3_bucket_public_access_block.example]  # Ensure it runs after the public access block

#   bucket = aws_s3_bucket.my_bucket.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect    = "Allow"
#         Principal = "*"
#         Action    = "s3:GetObject"
#         Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
#       }
#     ]
#   })
# }

# resource "aws_s3_bucket_acl" "example" {
#   depends_on = [
#     aws_s3_bucket_public_access_block.example,
#     aws_s3_bucket_policy.my_bucket_policy,  # Ensure this runs after the bucket policy
#   ]

#   bucket = aws_s3_bucket.my_bucket.id
#   acl    = "public-read"
# }
