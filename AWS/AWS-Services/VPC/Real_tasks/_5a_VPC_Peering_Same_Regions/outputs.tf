output "A_EC2_PUBLIC_SSH_Command" {
    value = "ssh -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.a_public_ec2.public_ip}"
}
output "B_EC2_PUBLIC_SSH_Command" {
    value = "ssh -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.b_public_ec2.public_ip}"
}
output "C_EC2_PUBLIC_SSH_Command" {
    value = "ssh -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.c_public_ec2.public_ip}"
}


output "PUBLIC_EC2_A_SSH_Command_TO_PUBLIC_EC2_B" {
    value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.b_public_ec2.private_ip}"
}
output "PUBLIC_EC2_A_SSH_Command_TO_PRIVATE_EC2_B" {
    value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.b_private_ec2.private_ip}"
}

output "PUBLIC_EC2_A_SSH_Command_TO_PUBLIC_EC2_C" {
    value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.c_public_ec2.private_ip}"
}
output "PUBLIC_EC2_A_SSH_Command_TO_PRIVATE_EC2_C" {
    value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.c_private_ec2.private_ip}"
}

output "PUBLIC_EC2_B_SSH_Command_TO_PUBLIC_EC2_C" {
    value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.c_public_ec2.private_ip}"
}
output "PUBLIC_EC2_B_SSH_Command_TO_PRIVATE_EC2_C" {
    value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.c_private_ec2.private_ip}"
}

output "PUBLIC_EC2_C_SSH_Command_TO_PUBLIC_EC2_A" {
    value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.a_public_ec2.private_ip}"
}
output "PUBLIC_EC2_C_SSH_Command_TO_PRIVATE_EC2_B" {
    value = "ssh -i /home/ubuntu/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.b_private_ec2.private_ip}"
}

output "ssh_key_to_ec2Apublic" {
    value = "scp -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.a_public_ec2.public_ip}:/home/ubuntu/"    
}
output "ssh_key_to_ec2Bpublic" {
    value = "scp -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.b_public_ec2.public_ip}:/home/ubuntu/"    
}

output "ssh_key_to_ec2Cpublic" {
    value = "scp -i ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ~/DevOps/ssh-keys/Princewill-ssh-bayero-sub.pem ubuntu@${aws_instance.c_public_ec2.public_ip}:/home/ubuntu/"    
}

# output "VPC_Peering_Connection_IDs" {
#     value = {
#         A_to_B = aws_vpc_peering_connection.a_b.id
#         A_to_C = aws_vpc_peering_connection.a_c.id
#         B_to_C = aws_vpc_peering_connection.b_c.id
#     }
# }
# output "VPC_Peering_Connection_Status" {
#     value = {
#         A_to_B = aws_vpc_peering_connection.a_b.status
#         A_to_C = aws_vpc_peering_connection.a_c.status
#         B_to_C = aws_vpc_peering_connection.b_c.status
#     }
# }
# output "VPC_Peering_Connection_Accepter_Owner_IDs" {
#     value = {
#         A_to_B = aws_vpc_peering_connection.a_b.accepter.owner_id
#         A_to_C = aws_vpc_peering_connection.a_c.accepter.owner_id
#         B_to_C = aws_vpc_peering_connection.b_c.accepter.owner_id
#     }
# }
# output "VPC_Peering_Connection_Requester_Owner_IDs" {
#     value = {
#         A_to_B = aws_vpc_peering_connection.a_b.requester.owner_id
#         A_to_C = aws_vpc_peering_connection.a_c.requester.owner_id
#         B_to_C = aws_vpc_peering_connection.b_c.requester.owner_id
#     }
# }
# output "VPC_Peering_Connection_Accepter_VPC_IDs" {
#     value = {
#         A_to_B = aws_vpc_peering_connection.a_b.accepter.vpc_id
#         A_to_C = aws_vpc_peering_connection.a_c.accepter.vpc_id
#         B_to_C = aws_vpc_peering_connection.b_c.accepter.vpc_id
#     }
# }
# output "VPC_Peering_Connection_Requester_VPC_IDs" {
#     value = {
#         A_to_B = aws_vpc_peering_connection.a_b.requester.vpc_id
#         A_to_C = aws_vpc_peering_connection.a_c.requester.vpc_id
#         B_to_C = aws_vpc_peering_connection.b_c.requester.vpc_id
#     }
# }
