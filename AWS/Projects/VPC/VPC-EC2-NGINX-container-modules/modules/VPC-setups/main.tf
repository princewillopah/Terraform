
# vpc
resource "aws_vpc" "myapp-vpc" {
  cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.vpc_env_prefix}-vpc"
  }
}

# 
# subnet
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = aws_vpc.myapp-vpc.id  #the only requiered atteributes
  cidr_block = var.subnet_cidr_block
  availability_zone = var.VPC_avail_zone
  tags = {
    Name = "${var.vpc_env_prefix}-subnet-1"
  }
}

# this is to create an internet gateway. An Internet Gateway is a logical connection between an AWS VPC and the Internet. It allows for internet traffic to actually enter into a VPC
resource "aws_internet_gateway" "myapp-internet-gateway" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "${var.vpc_env_prefix}-internet-gateway"
  }
}

# # THIS DEFAULT ROUTE TABLE IS USED WHEN WE WANT TO USE THE DEFUAULT TABLE ASSOCIATED WITH THE VCP WE CREATED
# we are going to use the default route-table created instaed of creating a new one shoew below after this default block
resource "aws_default_route_table" "default-route-table" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

   route { #this is perovided by default. This means that omitting this argument is interpreted as ignoring any existing routes. To remove all managed routes an empty list should be specified
    # cidr_block = "10.1.0.0/16"  this line will be provided by default if not specified. it picks the vpc cidr ip
     cidr_block = "0.0.0.0/0" # this is fer te internet gateway
    gateway_id = aws_internet_gateway.myapp-internet-gateway.id
  }
  tags = {
    Name = "${var.vpc_env_prefix}-default-router-table"
  }
}

# note, if route table is not created using the terraform during generation of the vpc, aws will create a default route table for you, 
# specifying the using cidr ip  of the vpc. the route object will be "local" stating that the traffic can only be within the vpc
# resource "aws_route_table" "myapp-router-table" {
#  vpc_id = aws_vpc.myapp-vpc.id

#   # since this is exactly the route AWS will create, the route will be adopted
#   route { #this is perovided by default. This means that omitting this argument is interpreted as ignoring any existing routes. To remove all managed routes an empty list should be specified
#     # cidr_block = "10.1.0.0/16"  this line will be provided by default if not specified. it picks the vpc cidr ip
#      cidr_block = "0.0.0.0/0" # this is fer te internet gateway
#     gateway_id = aws_internet_gateway.myapp-internet-gateway.id
#   }
#   tags = {
#     Name = "${var.env_prefix}-router-table"
#   }
# }

# # associate the subnet to a route table
# resource "aws_route_table_association" "associate-rtbl-subnet" {
#   subnet_id      = aws_subnet.myapp-subnet-1.id
#   route_table_id = aws_route_table.myapp-router-table.id
# }



