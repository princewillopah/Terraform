# # CloudFront + OAC (Modern & Secure)

# resource "aws_cloudfront_origin_access_control" "oac" {
#   name                              = "${var.project_name}-oac"
#   description                       = "Origin Access Control for ${var.project_name} CloudFront Distribution"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }
# resource "aws_cloudfront_distribution" "cdn" {
#   enabled             = true
#   is_ipv6_enabled     = true # not required, but recommended
#   comment             = "${var.project_name} CloudFront Distribution" # not required, but recommended
#   default_root_object = "index.html"
#    web_acl_id = aws_wafv2_web_acl.site.arn # Attach WAF Web ACL to CloudFront Distribution // pls remove if not using WAF
 
#  aliases = [
#     var.domain_name,
#     "www.${var.domain_name}"
#   ]


#   origin {
#     domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
#     origin_id                = "s3-${aws_s3_bucket.site.id}"
#     origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
#   }

#   default_cache_behavior {
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = "s3-${aws_s3_bucket.site.id}"

#     forwarded_values {
#       query_string = false
#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   viewer_certificate {
#     # acm_certificate_arn      = aws_acm_certificate.cert.arn # Using the ACM Certificate created earlier for CloudFront HTTPS support - you can also use the certificate validation "aws_acm_certificate_validation.cert_validation.certificate_arn"
#     acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
#     ssl_support_method       = "sni-only"
#     minimum_protocol_version = "TLSv1.2_2021"
#   }

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   tags = {
#     Name = "${var.project_name}-cloudfront-distribution"
#     # Environment = var.environment
#   }
# }
# # Output CloudFront Domain Name
# output "cloudfront_domain_name" {
#   description = "CloudFront Distribution Domain Name"
#   value       = aws_cloudfront_distribution.cdn.domain_name
# }
# # Output CloudFront Distribution ID
# output "cloudfront_distribution_id" {
#   description = "CloudFront Distribution ID"
#   value       = aws_cloudfront_distribution.cdn.id
# }
# # Output Origin Access Control ID
# output "cloudfront_oac_id" {
#   description = "CloudFront Origin Access Control ID"
#   value       = aws_cloudfront_origin_access_control.oac.id
# }
