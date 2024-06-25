# output "instance_public_ips" {
#   value = { for k, instance in aws_instance.EKS-Bootstrap-Server : k => instance.public_ip }
# }

# output "ssh_key" {
#   value = "${pathexpand(var.home_directory)}/${var.key_name}"
# }

output "connection_to_servers" {
  value = { for k, instance in aws_instance.my-Servers : k => "ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${instance.public_ip}" }
}

output "OUTPUTS" {
  value = "---------------------------------\nOUTPUTS\n-----------------------------"
}
