# output "jenkins_master_public_ip" {
#   value = aws_instance.Jenkin-Master-EC2-Instance.public_ip
# }

# output "jenkins_slave1_public_ip" {
#   value = aws_instance.Jenkin-Slave1-EC2-Instance.public_ip
# }

# output "ansible_instance_public_ip" {
#   value = aws_instance.Ansible-EC2-Instance.public_ip
# }
///////



output "connection_string_for_app_server" {
  value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.EC2_Instance_1.public_ip}"
}
output "connection_string_for_db_server" {
  value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.EC2_Instance_2.public_ip}"
}
output "connection_string_for_memcache_server" {
  value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.EC2_Instance_3.public_ip}"
}
output "connection_string_for_rabbitmq_server" {
  value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.EC2_Instance_4.public_ip}"
}
# output "connection_string_for_web_server" {
#   value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.EC2-Instance-5.public_ip}"
# }





output "OUTPUTS" {
  value = "---------------------------------\nOUTPUTS\n-----------------------------"
}
