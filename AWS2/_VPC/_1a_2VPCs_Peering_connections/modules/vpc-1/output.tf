output "vpc1_id" {  # to be used by vpc1_to_vpc2_peering_connection module
   value       = aws_vpc.main.id
}

output "vpc1_private_rt" {  # to be used by vpc1_to_vpc2_peering_connection module
   value       = aws_route_table.private_rt.id
}

output "vpc1_cidr" {
   value       = aws_vpc.main.cidr_block
}


output "vpc_1_public_instance_ip" { 
   value      = aws_instance.public_instance.public_ip 
}
output "vpc_1_private_instance_ip" { 
   value      = aws_instance.private_instance.private_ip 
}