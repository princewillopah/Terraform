


output "connection_to_server" {
  value = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${aws_instance.public_instance.public_ip}"
  # value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.Monitoring_Prometheus_target_Server.public_ip}"
}
