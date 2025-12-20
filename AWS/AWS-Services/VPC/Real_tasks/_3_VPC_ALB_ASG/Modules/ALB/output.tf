# ==========================================================================
# Outputs
# ==========================================================================

output "alb_arn" {
  value = aws_lb.app_alb.arn
}
output "alb_target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}
output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}


output "alb_dns_name" { # will be used by the DNS module
  value = aws_lb.app_alb.dns_name
}
output "alb_zone_id" { # will be used by the DNS module
  value = aws_lb.app_alb.zone_id
}

