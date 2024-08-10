# provider "aws" {
#   region = "eu-north-1"
# }

# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "5.61.0"
#     }
#   }
# }

# resource "aws_vpc" "main" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true
# }

# resource "aws_subnet" "public" {
#   count                   = 3  # This sets the number of subnet resources to create to 3  - Terraform will create three subnets, indexed from 0 to 2
#   vpc_id                  = aws_vpc.main.id  # This assigns the ID of the VPC (Virtual Private Cloud) to which the subnets will belong
#   cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index)   # This uses the cidrsubnet function to calculate the CIDR block for each subnet / it uses The base CIDR block of the VPC: "aws_vpc.main.cidr_block" /  3: The number of additional bits to add to the subnet mask, which creates subnets within the VPC  //   count.index: The current index in the count loop (0, 1, or 2), used to calculate unique subnets.
#   map_public_ip_on_launch = true
#   availability_zone       = element(["eu-north-1a", "eu-north-1b", "eu-north-1c"], count.index)  # count.index: The current index in the count loop (0, 1, or 2), used to calculate unique subnets.
# }

# resource "aws_subnet" "private" {
#   count             = 3
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index + 3)
#   availability_zone = element(["eu-north-1a", "eu-north-1b", "eu-north-1c"], count.index)
# }


# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id
# }

# resource "aws_eip" "nat" {
#    domain = "vpc"
# }

# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public[0].id
# }

# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
# }

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main.id
#   }
# }

# resource "aws_route_table_association" "public" {
#   count          = 3
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route_table_association" "private" {
#   count          = 3
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id = aws_route_table.private.id
# }

# resource "aws_security_group" "main" {
#   vpc_id = aws_vpc.main.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["192.168.167.30/32"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
