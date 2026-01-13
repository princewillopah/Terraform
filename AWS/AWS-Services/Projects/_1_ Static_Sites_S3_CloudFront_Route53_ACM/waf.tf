# # WAF 
# # 1. Create WAF Web ACL
# resource "aws_wafv2_web_acl" "site" {
#   name        = "${var.project_name}-web-acl"
#   description = "WAF for ${var.project_name}"
#   scope       = "CLOUDFRONT"  # Must be CLOUDFRONT for CloudFront
#   default_action {
#     allow {}
#   }
#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     sampled_requests_enabled   = true
#     metric_name                = "${var.project_name}-web-acl"
#   }

#   # Optional: Managed rule groups (recommended for production)
#   rule {
#     name     = "AWSManagedRulesCommonRuleSet"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       sampled_requests_enabled   = true
#       metric_name                = "AWSManagedRulesCommonRuleSet"
#     }
#   }
# }

# # 2. Attach WAF to CloudFront Distribution
# # (This is done in cloudfront.tf by adding the web_acl_id attribute to the aws_cloudfront_distribution resource)
