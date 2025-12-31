# ---------------------------------------------------------------------------------------------------------------------------------------------
#  connectivity
# ---------------------------------------------------------------------------------------------------------------------------------------------

output "jump_server_1a_connectivity_string" {
  value = "ssh -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.web_Server_1a.public_ip}"
}

output "web_server_1a_connectivity_string" {
  value = "ssh -i Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.web_Server_1a.private_ip}"
}
output "web_server_1b_connectivity_string" {
  value = "ssh -i Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.web_Server_1b.private_ip}"
}

output "app_server_1a_connectivity_string" {
  value = "ssh -i Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.app_Server_1a.private_ip}"
}
output "app_server_1b_connectivity_string" {
  value = "ssh -i Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.app_Server_1b.private_ip}"
}
output "db_server_1a_connectivity_string" {
  value = "ssh -i Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.db_Server_1a.private_ip}"
}

# ---------------------------------------------------------------------------------------------------------------------------------------------
#  Private IPs
# ---------------------------------------------------------------------------------------------------------------------------------------------

output "web_server_1a_private_ip" {
  value = aws_instance.web_Server_1a.private_ip
}
output "web_server_1b_private_ip" {
  value = aws_instance.web_Server_1b.private_ip 
}
output "app_server_1a_private_ip" {
  value = aws_instance.app_Server_1a.private_ip
}
output "app_server_1b_private_ip" {
  value = aws_instance.app_Server_1b.private_ip
}
output "db_server_1a_private_ip" {
  value = aws_instance.db_Server_1a.private_ip    
}
# ---------------------------------------------------------------------------------------------------------------------------------------------
#  Public IPs
# ---------------------------------------------------------------------------------------------------------------------------------------------
output "jump_server_1a_public_ip" {
  value = aws_instance.web_Server_1a.public_ip
}
output "web_server_1a_public_ip" {
  value = aws_instance.web_Server_1a.public_ip
}
output "web_server_1b_public_ip" {
  value = aws_instance.web_Server_1b.public_ip 
}
output "app_server_1a_public_ip" {
  value = aws_instance.app_Server_1a.public_ip
}
output "app_server_1b_public_ip" {
  value = aws_instance.app_Server_1b.public_ip
}
output "db_server_1a_public_ip" {
  value = aws_instance.db_Server_1a.public_ip    
}









# ---------------------------------------------------------------------------------------------------------------------------------------------
#  connectivity
# ---------------------------------------------------------------------------------------------------------------------------------------------


