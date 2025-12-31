output "private_ec2_instance_id" {
  description = "The ID of the private EC2 instance"
  value       = "aws ssm start-session --target ${aws_instance.data_tier.id}"
}

# resource "aws_security_group" "jump-host-security-group" {
#   name   = "jump-host-security-group"

#   vpc_id      = var.vpc_id


