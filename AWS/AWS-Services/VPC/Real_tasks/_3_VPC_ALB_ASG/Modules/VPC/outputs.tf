output "vpc_id" {value = aws_vpc.app_vpc.id }
output "public_subnet_ids" {value = values(aws_subnet.public_subnets)[*].id }
output "private_app_subnet_ids" {value = values(aws_subnet.private_subnets)[*].id }
output "public_subnet_az1_id" {value = aws_subnet.public_subnets["az1"].id} // jumpserver will need this specific public subnet ID

# output "nat_gateway_ids" {value = aws_nat_gateway.nat[*].id }
# output "azs_used" {value = var.azs }




# output "public_subnet_az1_id" {value = aws_subnet.public_subnet_az1.id }
# output "public_subnet_az2_id" {value = aws_subnet.public_subnet_az2.id}