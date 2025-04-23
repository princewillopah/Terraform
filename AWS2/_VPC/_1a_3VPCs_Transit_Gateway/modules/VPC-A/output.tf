output "vpc_A_id" { 
   value       = aws_vpc.main.id
}

output "vpc_A_subnets_ids" { 
  description = "List of subnet IDs"
  value       = aws_subnet.private_subnet[*].id  # Assuming you create multiple subnets
}
  

output "vpcA_private_rt" { 
   value       = aws_route_table.private_rt.id
}

output "vpcA_cidr" {
   value       = aws_vpc.main.cidr_block
}


output "vpc_A_public_instance_ip" { 
   value      = aws_instance.public_instance.public_ip 
}
output "vpc_A_private_instance_ip" { 
   value      = aws_instance.private_instance.private_ip 
}