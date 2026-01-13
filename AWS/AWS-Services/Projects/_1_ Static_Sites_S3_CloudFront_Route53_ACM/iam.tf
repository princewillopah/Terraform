

# data "aws_iam_policy_document" "site" {
#   statement {
#     actions   = ["s3:GetObject"]
#     resources = ["${aws_s3_bucket.site.arn}/*"]

#     principals {
#       type        = "Service"
#       identifiers = ["cloudfront.amazonaws.com"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceArn"
#       values   = [aws_cloudfront_distribution.cdn.arn]
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "site" {
#   bucket = aws_s3_bucket.site.id
#   policy = data.aws_iam_policy_document.site.json
# }





# # S3 Bucket Policy (CloudFront Only)
# resource "aws_iam_policy" "s3_bucket_policy" {
#   name        = "${var.project_name}-s3-bucket-policy"
#   description = "S3 Bucket Policy to allow CloudFront access via Origin Access Control"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "cloudfront.amazonaws.com"
#         }
#         Action = "s3:GetObject"
#         Resource = "${aws_s3_bucket.site.arn}/*"
#         Condition = {
#           StringEquals = {
#             "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
#           }
#         }
#       }
#     ]
#   })
# }
# # Attach S3 Bucket Policy
# resource "aws_iam_policy_attachment" "s3_bucket_policy_attachment" {
#   name       = "${var.project_name}-s3-bucket-policy-attachment"
#   policy_arn = aws_iam_policy.s3_bucket_policy.arn
#   roles      = [aws_iam_role.cloudfront_oac_role.name]
# }



# # Output S3 Bucket Name
# output "s3_bucket_name" {
#   description = "S3 Bucket Name for Static Site"
#   value       = aws_s3_bucket.site.bucket
# }
# # Output S3 Bucket ARN  
# output "s3_bucket_arn" {
#   description = "S3 Bucket ARN for Static Site"
#   value       = aws_s3_bucket.site.arn
# }
# # Output S3 Bucket Policy ARN
# output "s3_bucket_policy_arn" {
#   description = "S3 Bucket Policy ARN"
#   value       = aws_iam_policy.s3_bucket_policy.arn
# }
# # Output S3 Bucket Policy Attachment Name
# output "s3_bucket_policy_attachment_name" {
#   description = "S3 Bucket Policy Attachment Name"
#   value       = aws_iam_policy_attachment.s3_bucket_policy_attachment.name
# }
# # Output IAM Role Name for CloudFront Origin Access Control
# output "cloudfront_oac_role_name" {
#   description = "IAM Role Name for CloudFront Origin Access Control"
#   value       = aws_iam_role.cloudfront_oac_role.name
# }
# # Output IAM Role ARN for CloudFront Origin Access Control
# output "cloudfront_oac_role_arn" {
#   description = "IAM Role ARN for CloudFront Origin Access Control"
#   value       = aws_iam_role.cloudfront_oac_role.arn
# }   
# output "cloudfront_oac_id" {
#   description = "Origin Access Control ID"
#   value       = aws_cloudfront_origin_access_control.oac.id
# }   
