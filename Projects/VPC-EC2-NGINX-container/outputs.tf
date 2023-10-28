output "myapp_server_public_output"{
    value = aws_instance.myapp-EC2-instance.public_ip
}