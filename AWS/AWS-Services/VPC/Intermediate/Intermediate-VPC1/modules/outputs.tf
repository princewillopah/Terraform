
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = values(aws_subnet.public)[*].id
}

output "app_subnet_ids" {
  value = values(aws_subnet.app)[*].id
}

output "data_subnet_ids" {
  value = values(aws_subnet.data)[*].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat[*].id
}

output "azs_used" {
  value = var.azs
}

