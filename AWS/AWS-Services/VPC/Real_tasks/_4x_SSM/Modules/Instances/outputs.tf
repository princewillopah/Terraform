# output "public_ip" {value = aws_instance.Jump-Server.public_ip }
# output "jump_sg_id" {value = aws_security_group.jump-host-security-group.id }


# output "instance_ids" {
#   value = { for k, inst in aws_instance.fleet : k => inst.id }
# }

# output "private_ips" {
#   value = { for k, inst in aws_instance.fleet : k => inst.private_ip }
# }

# output "public_ips" {
#   value = { for k, inst in aws_instance.fleet : k => inst.public_ip }
# }
