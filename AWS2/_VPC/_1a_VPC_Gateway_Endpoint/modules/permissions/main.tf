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
                ${join(",", [for i in range(var.bucket_count) : "\"arn:aws:s3:::princewill-${var.bucket_prefix}-${i + 1}\""])},
                ${join(",", [for i in range(var.bucket_count) : "\"arn:aws:s3:::princewill-${var.bucket_prefix}-${i + 1}/*\""])}
            ]
        }
    ]
}
EOF
}



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


# ------------------------------


# resource "aws_iam_policy" "s3_policy" {
#   name        = "S3AccessPolicy"
#   description = "IAM policy for S3 bucket access"
#   policy      = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:ListBucket",
#                 "s3:GetObject",
#                 "s3:PutObject",
#                 "s3:DeleteObject"
#             ],
#             "Resource": [
#                 "arn:aws:s3:::my-example-bucket-xxx",
#                 "arn:aws:s3:::my-example-bucket-xxx/*"
#             ]
#         }
#     ]
# }
# EOF
# }