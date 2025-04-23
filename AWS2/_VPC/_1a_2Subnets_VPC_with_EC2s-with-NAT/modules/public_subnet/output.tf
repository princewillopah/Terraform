output "public_instance_ip" { 
   value      = aws_instance.public_instance.public_ip 
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.main-nat.id
}