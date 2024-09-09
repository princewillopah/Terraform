output "jenkin-master-instance_public_ip" {
  value = aws_instance.Jenkins-Master-Instance.public_ip
}

# output "jenkins_slave1_public_ip" {
#   value = aws_instance.Jenkin-Slave1-EC2-Instance.public_ip
# }

# output "ansible_instance_public_ip" {
#   value = aws_instance.Ansible-EC2-Instance.public_ip
# }
# -------------------------------
# linux
# ----------------------------

# output "user" {
#   value = "ubuntu"
# }

# output "IP_Address" {
#   value = aws_instance.Jenkins-Master-Instance.public_ip
# }

# output "ssh_key" {
#   value = "${pathexpand(var.home_directory)}/${var.key_name}"
# }

# output "connection_to_server" {
#   value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.Jenkins-Master-Instance.public_ip}"
# }

# output "OUTPUTS" {
#   value = "---------------------------------\nOUTPUTS\n-----------------------------"
# }

# -------------------------------------------------
# # windos
# ------------------------------------------------

output "connection_to_jenkins_master_server" {
  value = " ssh -i ~/.ssh/${var.key_name} ubuntu@${aws_instance.Jenkins-Master-Instance.public_ip}"
  # value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.Monitoring_Prometheus_target_Server.public_ip}"
}

output "OUTPUTS" {
  value = "---------------------------------\nOUTPUTS\n-----------------------------"
}

