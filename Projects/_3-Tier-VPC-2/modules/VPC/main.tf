# create vpc
resource "aws_vpc" "my_vpc" {
  cidr_block              = var.vpc_cidr
  instance_tenancy        = "default"
  enable_dns_hostnames    = true

  tags      = {
    Name    = "${var.project_name}-vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = aws_vpc.my_vpc.id

  tags      = {
    Name    = "${var.project_name}-igw"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# Create public subnets within the AWS VPC using the "aws_subnet" resource.
resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnet_cidrs)  # Create one subnet per value in public_subnet_cidrs
  vpc_id     = aws_vpc.main.id                   # Associate these subnets with an existing VPC
  cidr_block = element(var.public_subnet_cidrs, count.index)  # Use the CIDR block from the variable list
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "Public Subnet ${count.index + 1}"  # Name each subnet uniquely based on its index
  }
}
# create public subnet az1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = 
  cidr_block              = 
  availability_zone       = 
  map_public_ip_on_launch = 

  tags      = {
    Name    = 
  }
}

# # create public subnet az2
# resource "aws_subnet" "public_subnet_az2" {
#   vpc_id                  = 
#   cidr_block              = 
#   availability_zone       = 
#   map_public_ip_on_launch = 

#   tags      = {
#     Name    = 
#   }
# }

# # create route table and add public route
# resource "aws_route_table" "public_route_table" {
#   vpc_id       = 

#   route {
#     cidr_block = 
#     gateway_id = 
#   }

#   tags       = {
#     Name     = 
#   }
# }

# # associate public subnet az1 to "public route table"
# resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
#   subnet_id           = 
#   route_table_id      = 
# }

# # associate public subnet az2 to "public route table"
# resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
#   subnet_id           = 
#   route_table_id      = 
# }

# # create private app subnet az1
# resource "aws_subnet" "private_app_subnet_az1" {
#   vpc_id                   = 
#   cidr_block               = 
#   availability_zone        = 
#   map_public_ip_on_launch  = 

#   tags      = {
#     Name    = 
#   }
# }

# # create private app subnet az2
# resource "aws_subnet" "private_app_subnet_az2" {
#   vpc_id                   = 
#   cidr_block               = 
#   availability_zone        = 
#   map_public_ip_on_launch  = 

#   tags      = {
#     Name    = 
#   }
# }

# # create private data subnet az1
# resource "aws_subnet" "private_data_subnet_az1" {
#   vpc_id                   = 
#   cidr_block               = 
#   availability_zone        = 
#   map_public_ip_on_launch  = 

#   tags      = {
#     Name    = 
#   }
# }

# # create private data subnet az2
# resource "aws_subnet" "private_data_subnet_az2" {
#   vpc_id                   = 
#   cidr_block               = 
#   availability_zone        = 
#   map_public_ip_on_launch  = 

#   tags      = {
#     Name    = 
#   }
# }

