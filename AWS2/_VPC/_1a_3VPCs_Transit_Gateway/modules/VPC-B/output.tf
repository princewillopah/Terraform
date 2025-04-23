output "vpc_B_id" {
   value       = aws_vpc.main.id
}
output "vpc_B_subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.private_subnet.id  # Assuming a single subnet is created
}

output "vpc_B_cidr" {
   value       = aws_vpc.main.cidr_block
}


output "vpc_B_private_rt" {  # to be used by vpc1_to_vpc_B_peering_connection module
   value       = aws_route_table.private_rt.id
}


output "vpc_B_private_instance_ip" { 
   value      = aws_instance.private_instance.private_ip 
}