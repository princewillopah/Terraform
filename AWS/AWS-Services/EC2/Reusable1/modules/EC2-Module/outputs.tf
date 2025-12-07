output "instance_ids" {
  value = { for k, inst in aws_instance.fleet : k => inst.id }
}

output "private_ips" {
  value = { for k, inst in aws_instance.fleet : k => inst.private_ip }
}

output "public_ips" {
  value = { for k, inst in aws_instance.fleet : k => inst.public_ip }
}
