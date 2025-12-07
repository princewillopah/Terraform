output "wed_server_public_ip" {
  value = aws_instance.web-Server.public_ip
}

output "app_server_private_ip" {
  value = aws_instance.app-Server.private_ip
}

output "data_server_private_ip" {
  value = aws_instance.data-Server.private_ip
}

output "public_connection_string" {
  value = "ssh -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.web-Server.public_ip}"
}

output "app-server_connection_string" {
  value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.app-Server.private_ip}"
}


output "data-server_connection_string" {
  value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.data-Server.private_ip}"
}