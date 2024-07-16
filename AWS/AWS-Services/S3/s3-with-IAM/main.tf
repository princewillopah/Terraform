# We'll start by defining the S3 bucket with some basic configurations
resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket-xxx"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      days = 90
    }

    abort_incomplete_multipart_upload_days = 7
  }

  tags = {
    Name        = "My example bucket xxx"
    Environment = "Dev"
  }
}

# create an IAM policy that grants permissions to interact with the S3 bucket
resource "aws_iam_policy" "s3_policy" {
  name        = "S3AccessPolicy"
  description = "IAM policy for S3 bucket access"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::my-example-bucket-xxx",
                "arn:aws:s3:::my-example-bucket-xxx/*"
            ]
        }
    ]
}
EOF
}

# create an IAM role and attach the policy to to the role
resource "aws_iam_role" "s3_access_role" {
  name = "S3AccessRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_access_policy_attachment" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}
