output "instance_public_ip" {
  value = aws_instance.T3-Medium-Server.public_ip
}

# output "jenkins_slave1_public_ip" {
#   value = aws_instance.Jenkin-Slave1-EC2-Instance.public_ip
# }

# output "ansible_instance_public_ip" {
#   value = aws_instance.Ansible-EC2-Instance.public_ip
# }


# -------------------------------------------------
# # windos
# ------------------------------------------------

output "connection_to_server" {
  value = " ssh -i ~/.ssh/${var.key_name} ubuntu@${aws_instance.T3-Medium-Server.public_ip}"
  # value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.Monitoring_Prometheus_target_Server.public_ip}"
}

output "OUTPUTS" {
  value = "---------------------------------\nOUTPUTS\n-----------------------------"
}