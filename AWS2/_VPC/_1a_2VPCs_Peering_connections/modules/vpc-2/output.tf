output "vpc2_id" {
   value       = aws_vpc.main.id
}

output "vpc2_cidr" {
   value       = aws_vpc.main.cidr_block
}


output "vpc2_private_rt" {  # to be used by vpc1_to_vpc2_peering_connection module
   value       = aws_route_table.private_rt.id
}


output "vpc_2_private_instance_ip" { 
   value      = aws_instance.private_instance.private_ip 
}