# output "instance_public_ip" {
#   value = aws_instance.EKS-Bootstrap-Server.public_ip
# }
# output "ssh_connection_command" {
#   value = "Connect with \"ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.EKS-Bootstrap-Server.public_ip}\""
# }






output "connection_to_linux_server" {
  value = " ssh -i ~/.ssh/${var.key_name} ubuntu@${aws_instance.Linux-Server.public_ip}"
  # value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.Monitoring_Prometheus_target_Server.public_ip}"
}

# output "jenkins_slave1_public_ip" {
#   value = aws_instance.Jenkin-Slave1-EC2-Instance.public_ip
# }

# output "ansible_instance_public_ip" {
#   value = aws_instance.Ansible-EC2-Instance.public_ip
# }
