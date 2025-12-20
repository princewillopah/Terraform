output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}

output "alb_arn" {
  value = aws_lb.web_alb.arn
}

output "asg_name" {
  value = aws_autoscaling_group.web_asg.name
}
