output "asg_name" {
  value = aws_autoscaling_group.app_auto_scaling_group.name
}

output "launch_template_id" {
  value = aws_launch_template.app_server_launch_template.id
}
