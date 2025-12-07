output "instance_ids" {
  description = "Map of instance IDs keyed by instance name"
  value = { for k, v in aws_instance.this : k => v.id }
}

output "public_ips" {
  description = "Map of public IPs (if assigned)"
  value = { for k, v in aws_instance.this : k => v.public_ip }
}

output "private_ips" {
  description = "Map of private IPs"
  value = { for k, v in aws_instance.this : k => v.private_ip }
}