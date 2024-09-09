# -------------------------------------------------
# # windos
# ------------------------------------------------

output "connection_to_sonarsube_server" {
  value = " ssh -i ~/.ssh/${var.key_name} ubuntu@${aws_instance.SonarQube-Server.public_ip}"
  # value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.Monitoring_Prometheus_target_Server.public_ip}"
}

output "OUTPUTS" {
  value = "---------------------------------\nOUTPUTS\n-----------------------------"
}