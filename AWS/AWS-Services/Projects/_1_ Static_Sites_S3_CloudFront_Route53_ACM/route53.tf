# # ------------------------------------------------------------------
# # Creating Route 53 Hosted Zone
# # ------------------------------------------------------------------
# resource "aws_route53_zone" "primary" {
#   name = var.domain_name

#   comment = "Public hosted zone for ${var.domain_name}"
# }


# # Route 53 Alias Record for Apex Domain "princewill-opah.name.ng"
# resource "aws_route53_record" "apex" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = var.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.cdn.domain_name
#     zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# # Route 53 Alias Record for "www.princewill-opah.name.ng"
# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = "www.${var.domain_name}"
#   type    = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.cdn.domain_name
#     zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
#     evaluate_target_health = false
#   }
# }


# # Route 53 Alias Record
# # resource "aws_route53_record" "site_alias" {
# #   zone_id = aws_route53_zone.primary.zone_id

# #   name    = "${var.subdomain}.${var.domain_name}"
# #   type    = "A"

# #   alias {
# #     name                   = aws_cloudfront_distribution.cdn.domain_name
# #     zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
# #     evaluate_target_health = false
# #   }
# # }

# ## Output nameservers:
# output "nameservers" {
#   value = aws_route53_zone.primary.name_servers
# }
# # # Output Route53 Record FQDN
# # output "route53_record_fqdn" {
# #     description = "Route53 Record FQDN for Static Site" 
# #     value       = aws_route53_record.site_alias.fqdn
# # }
# # # Output Route53 Record ID
# # output "route53_record_id" {
# #     description = "Route53 Record ID for Static Site" 
# #     value       = aws_route53_record.site_alias.id
# # }
# # # Output Route53 Zone ID
# # output "route53_zone_id" {
# #     description = "Route53 Zone ID for Static Site" 
# #     value       = aws_route53_record.site_alias.zone_id
# # }
