# ----------------------------------------------------------------------------------------
# Create a public hosted zone in Route 53 - Route53 Hosted Zone for princewill-opah.name.ng
# ----------------------------------------------------------------------------------------
resource "aws_route53_zone" "root" {
  name = var.domain_name
}
## this will generate NS records when the hosted zone is created
## you can view the name servers with the output below
## updated the dns record with the nameservers provided by aws route53 at the domain registrar
# output "nameservers" {
#   value = aws_route53_zone.root.name_servers
# }
# ----------------------------------------------------------------------------------------
# Request ACM certificate - this is DNS Validation (same region as ALB)
# ----------------------------------------------------------------------------------------

resource "aws_acm_certificate" "root_cert" {
    #  provider          = aws.us-east-1  # 👈 ONLY if your ALB is in us-east-1. Adjust if needed!
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "www.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.app_name} ALB Certificate - ${var.domain_name}"
  }
}
# ----------------------------------------------------------------------------------------
# Create DNS Validation Records, in Route 53, Automatically
# ----------------------------------------------------------------------------------------
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.root_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.root.zone_id
  name    = each.value.name
  type      = each.value.type
  ttl          = 60
  records = [each.value.record]
}


# ----------------------------------------------------------------------------------------
# # Validate ACM certificate - Tell ACM to Validate -Wait until ACM cert is issued
# ----------------------------------------------------------------------------------------
resource "aws_acm_certificate_validation" "root_cert_validation" {
  certificate_arn         = aws_acm_certificate.root_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


# ----------------------------------------------------------------------------------------
# Route 53 ALIAS record - root domain -> ALB
# ----------------------------------------------------------------------------------------
resource "aws_route53_record" "root_alias" {
  zone_id = aws_route53_zone.root.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# ----------------------------------------------------------------------------------------
# Route 53 ALIAS record - www subdomain -> ALB
# ----------------------------------------------------------------------------------------
resource "aws_route53_record" "www_alias" {
  zone_id = aws_route53_zone.root.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}




























































