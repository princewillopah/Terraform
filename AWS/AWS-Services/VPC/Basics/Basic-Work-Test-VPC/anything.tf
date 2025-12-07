# terraform {
#   required_version = ">= 1.0.0"

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 5.0"
#     }
#   }
# }

# provider "aws" {
#   region = "us-east-1"
# }


# ===========================================================================
# variables
# ===========================================================================

variable "my_app_name" {
  description = "VPC ID to deploy into"
  type        = string
  default = "xxxxx"
}

variable "region" {
  default = "us-east-1"
}

# ===========================================================================
# vpc
# ===========================================================================
resource "aws_vpc" "vpc_x" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.my_app_name}-VPC"
  }
}
# ===========================================================================
# IGW
# ===========================================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_x.id

  tags = {
    Name = "${var.my_app_name}-IGW"
  }
}


# ===========================================================================
# SUBNETS
# ===========================================================================
# PUBLIC SUBNETS
resource "aws_subnet" "web_public_subnet" {
  vpc_id                  = aws_vpc.vpc_x.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = { Name = "${var.my_app_name}-web_public_subnet_1a" }
}

# PRIVATE APP SUBNETS
resource "aws_subnet" "app_private_subnet" {
  vpc_id            = aws_vpc.vpc_x.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}a"

  tags = { Name = "${var.my_app_name}-app_private_subnet_1a" }
}

# PRIVATE DATA SUBNETS
resource "aws_subnet" "data_private_subnet" {
  vpc_id            = aws_vpc.vpc_x.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}a"

  tags = { Name = "${var.my_app_name}-data_private_subnet_1a" }
}

# ===========================================================================
# AWS ROUTE TABLES
# ===========================================================================

# create the public route table
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.vpc_x.id

  tags = {
    Name = "${var.my_app_name}-Public-Route-Table"
  }
}

# create the private route table
resource "aws_route_table" "private_app_RT" {
  vpc_id = aws_vpc.vpc_x.id

  tags = {
    Name = "${var.my_app_name}-App-Private-Route-Table"
  }
}

# create the private route table
resource "aws_route_table" "private_data_RT" {
  vpc_id = aws_vpc.vpc_x.id

  tags = {
    Name = "${var.my_app_name}-Data-Private-Route-Table"
  }
}

# ===========================================================================
#  ROUTE TABLE ASSOCIATIONS
# ===========================================================================




# PUBLIC SUBNET ASSOCIATIONS
resource "aws_route_table_association" "pub_1a" {
  subnet_id      = aws_subnet.web_public_subnet.id
  route_table_id = aws_route_table.public_RT.id
}

# PRIVATE SUBNET ASSOCIATIONS
resource "aws_route_table_association" "pvt_app_1a" {
  subnet_id      = aws_subnet.app_private_subnet.id
  route_table_id = aws_route_table.private_app_RT.id
}

resource "aws_route_table_association" "pvt_data_1a" {
  subnet_id      = aws_subnet.data_private_subnet.id
  route_table_id = aws_route_table.private_data_RT.id
}






# ===========================================================================
# NAT GATEWAY AND EIP
# ===========================================================================
# Elastic IP creation for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "${var.my_app_name}-nat-eip" }
}



resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.web_public_subnet.id

  tags = { Name = "${var.my_app_name}-nat" }
}






# ===========================================================================
# CONFIGURE ROUTES TO IGW AND NAT GATEWAY
# ===========================================================================
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public_RT.id
  destination_cidr_block = "0.0.0.0/0"  # This entry sends all other subnet traffic to the internet gateway, which enables the instances in the subnet to access the internet.
  gateway_id             = aws_internet_gateway.igw.id
}



resource "aws_route" "private_app_nat_route" {
  route_table_id         = aws_route_table.private_app_RT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# ===========================================================================
# 
# ===========================================================================