output "private_ec2_instance_id" {
  description = "The ID of the private EC2 instance"
  value       = "aws ssm start-session --target ${aws_instance.private_ec2.id}"
}