# output "project_name" {value = }
output "vpc_id" {value = aws_vpc.my_vpc.id}

output "public_subnet_ids" {
 value = aws_subnet.public_subnets[*].id
}

# output "public_subnet_az1_id" {value = aws_subnet.public_subnet_az1.id }
# output "public_subnet_az2_id" {value = aws_subnet.public_subnet_az2.id}

# output "private_app_subnet_az1_id" {value = aws_subnet.public_subnet_az1.id}
# output "private_app_subnet_az2_id" {value = aws_subnet.public_subnet_az1.id}
# output "private_data_subnet_az1_id" {value = aws_subnet.public_subnet_az1.id}
# output "private_data_subnet_az2_id" {value = aws_subnet.public_subnet_az1.id}