output "private_instance_private_ip"{ 
# value=aws_instance.private_instance.id 
 value       = aws_instance.private_instance.private_ip
}

