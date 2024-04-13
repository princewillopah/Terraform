
# vpc
resource "aws_vpc" "myEKS-vpc" {
  cidr_block       = var.vpc_cidr_block   // the only requiered atteributes


  tags = {
    Name = "${var.VPC_env_prefix}-vpc"
  }
}

# 
# subnet
resource "aws_subnet" "myEKS-subnet-1" {
  vpc_id     = aws_vpc.myEKS-vpc.id  #the only requiered atteributes
  cidr_block = "10.0.1.0/24"
  availability_zone = var.VPC_avail_zone[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.VPC_env_prefix}-subnet-1"
  }
}
# subnet
resource "aws_subnet" "myEKS-subnet-2" {
  vpc_id     = aws_vpc.myEKS-vpc.id  #the only requiered atteributes
  cidr_block = "10.0.2.0/24"
  availability_zone = var.VPC_avail_zone[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.VPC_env_prefix}-subnet-2"
  }
}

# this is to create an internet gateway. An Internet Gateway is a logical connection between an AWS VPC and the Internet. It allows for internet traffic to actually enter into a VPC
resource "aws_internet_gateway" "myEKS-internet-gateway" {
  vpc_id = aws_vpc.myEKS-vpc.id

  tags = {
    Name = "${var.VPC_env_prefix}-internet-gateway"
  }
}

resource "aws_route_table" "myEKS-router-table" {
 vpc_id = aws_vpc.myEKS-vpc.id

  # since this is exactly the route AWS will create, the route will be adopted
  route { #this is perovided by default. This means that omitting this argument is interpreted as ignoring any existing routes. To remove all managed routes an empty list should be specified
    # cidr_block = "10.1.0.0/16"  this line will be provided by default if not specified. it picks the vpc cidr ip
    cidr_block = "0.0.0.0/0" # this is fer te internet gateway
    gateway_id = aws_internet_gateway.myEKS-internet-gateway.id
  }
  tags = {
    Name = "${var.VPC_env_prefix}-router-table"
  }
}

# associate the subnet to a route table
resource "aws_route_table_association" "associate-rtbl-subnet1" {
  subnet_id      = aws_subnet.myEKS-subnet-1.id
  route_table_id = aws_route_table.myEKS-router-table.id
}

# associate the second subnet to a route table
resource "aws_route_table_association" "associate-rtbl-subnet2" {
  subnet_id      = aws_subnet.myEKS-subnet-2.id
  route_table_id = aws_route_table.myEKS-router-table.id
}




