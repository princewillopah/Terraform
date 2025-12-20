output "nameservers" {
  value = aws_route53_zone.root.name_servers
}
output "certificate_arn" {
  value = aws_acm_certificate_validation.root_cert_validation.certificate_arn
}
