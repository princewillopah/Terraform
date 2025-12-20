output "public_ip" {value = aws_instance.Jump-Server.public_ip }
output "jump_sg_id" {value = aws_security_group.jump-host-security-group.id }
