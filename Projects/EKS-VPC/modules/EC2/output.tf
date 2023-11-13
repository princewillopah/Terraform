output "module_EC2_server_public_output"{
    value = aws_instance.myEKS-worker-node-EC2-instance
}

output "module_EKS-SG"{
    value = aws_security_group.myEKS-security-group
}