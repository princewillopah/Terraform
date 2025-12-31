# ---------------------------------------------------------------------------------------------------------------------------------------------
#  connectivity
# ---------------------------------------------------------------------------------------------------------------------------------------------

output "jump_server_1a_connectivity_string" {
  value = "ssh -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.Jump_Server.public_ip}"
}

output "ssh_key_to_jump_server" {
  value = "scp -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.Jump_Server.public_ip}:/home/ubuntu/"
}

output "web_server_1a_connectivity_string" {
  value = "ssh -i Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.web_Server_1a.private_ip}"
}

output "app_server_1a_connectivity_string" {
  value = "ssh -i Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.app_Server_1a.private_ip}"
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

output "app_server_1a_private_ip" {
  value = aws_instance.app_Server_1a.private_ip
}

output "db_server_1a_private_ip" {
  value = aws_instance.db_Server_1a.private_ip    
}
# ---------------------------------------------------------------------------------------------------------------------------------------------
#  Public IPs
# ---------------------------------------------------------------------------------------------------------------------------------------------

output "web_server_1a_public_ip" {
  value = aws_instance.web_Server_1a.public_ip
}










# ---------------------------------------------------------------------------------------------------------------------------------------------
#  connectivity
# ---------------------------------------------------------------------------------------------------------------------------------------------


