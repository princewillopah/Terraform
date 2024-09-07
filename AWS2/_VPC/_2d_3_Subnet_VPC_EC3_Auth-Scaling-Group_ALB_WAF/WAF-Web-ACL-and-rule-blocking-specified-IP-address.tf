# ----------------------------------------------------
# Create the WAF Web ACL
# -----------------------------------------------------

resource "aws_wafv2_ip_set" "blocked_ips" {
  name        = "blocked-ips"
  description = "IP set to block specific IPs"
  scope       = "REGIONAL" # Use "CLOUDFRONT" for CloudFront distributions
  ip_address_version = "IPV4"

  addresses = [var.blocked_ip]
}

# ----------------------------------------------------
# Define a WAF Web ACL and a rule to block the specified IP address.
# -----------------------------------------------------
resource "aws_wafv2_web_acl" "web_acl" {
  name        = "web-acl"
  description = "Web ACL to block specific IPs"
  scope       = "REGIONAL"# Use "CLOUDFRONT" for CloudFront distributions

  default_action {
    allow {}
  }

  rule {
    name     = "block-my-laptop-ip"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked_ips.arn   # connecting thw waf acl ang the rules
      }
    }

    visibility_config {
      sampled_requests_enabled = true
      cloudwatch_metrics_enabled = true
      metric_name = "block-specific-ip"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl"
    sampled_requests_enabled   = true
  }
}
# ------------------------------------------------------------
# Associate the WAF Web ACL with an Application Load Balancer
# ------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = aws_lb.myapp-alb.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}













