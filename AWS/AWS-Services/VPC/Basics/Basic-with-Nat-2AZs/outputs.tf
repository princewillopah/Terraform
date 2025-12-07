output "vpc" {
  value = aws_vpc.three_tier
}


output "vpc_id" {
  value = aws_vpc.three_tier.id
}



output "public_subnet_ids" {
  value = [
    aws_subnet.web_public_subnet1a.id,
    aws_subnet.web_public_subnet1b.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.app_private_subnet1a.id,
    aws_subnet.app_private_subnet1b.id
  ]
}

output "data_subnet_ids" {
  value = [
    aws_subnet.data_private_subnet1a.id,
    aws_subnet.data_private_subnet1b.id
  ]
}

