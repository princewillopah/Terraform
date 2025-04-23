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

# output "connection_to_jenkins_master_server" {
#   value = " ssh -i ~/.ssh/${var.key_name} ubuntu@${aws_instance.Jenkins-Master-Instance.public_ip}"
#   # value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.Monitoring_Prometheus_target_Server.public_ip}"
# }

# output "OUTPUTS" {
#   value = "---------------------------------\nOUTPUTS\n-----------------------------"
# }

# # Output to provide the SSH connection command to the Jenkins master server
# output "connection_to_jenkins_master_server" {
#   value = "ssh -i ~/.ssh/${var.ssh-key} ubuntu@${aws_instance.Jenkins-Master-Instance.public_ip}"
# }

# # Output the public IP of the Jenkins master server
# output "jenkins_master_server_public_ip" {
#   value = aws_instance.Jenkins-Master-Instance.public_ip
# }

# # Output the IAM role name for the Jenkins instance
# output "jenkins_iam_role_name" {
#   value = aws_iam_role.jenkins_role.name
# }

# # Output the security group ID for the Jenkins instance
# output "jenkins_security_group_id" {
#   value = aws_security_group.Jenkins-sg.id
# }

# # General outputs section to label the outputs
# output "OUTPUTS" {
#   value = "---------------------------------\nOUTPUTS\n-----------------------------"
# }



output "connection_to_jenkins_master_server" {
  value = "ssh -i ~/.ssh/${var.ssh-key}.pem ubuntu@${aws_instance.Jenkins-Master-Instance.public_ip}"
}

output "jenkins_master_server_public_ip" {
  value = aws_instance.Jenkins-Master-Instance.public_ip
}

output "jenkins_iam_role_name" {
  value = aws_iam_role.jenkins_role.name
}

output "jenkins_security_group_id" {
  value = aws_security_group.Jenkins-sg.id
}

output "OUTPUTS" {
  value = "---------------------------------\nOUTPUTS\n-----------------------------"
}
