output "public_connection_string" {
  value = "ssh -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.Jump-Server.public_ip}"
}


output "app_private_subnet_connections" {
  value = [
    "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.app-Server1.private_ip}",
    "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.app-Server2.private_ip}"
  ]
}