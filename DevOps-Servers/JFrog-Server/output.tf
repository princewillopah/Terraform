output "instance_public_ip" {
  value = aws_instance.Nexus-Server.public_ip
}

# output "jenkins_slave1_public_ip" {
#   value = aws_instance.Jenkin-Slave1-EC2-Instance.public_ip
# }

# output "ansible_instance_public_ip" {
#   value = aws_instance.Ansible-EC2-Instance.public_ip
# }
