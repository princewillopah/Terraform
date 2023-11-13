

resource "aws_vpc" "EKS_VPC" {
 cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
 tags = {
   Name = "${var.environment}-VPC"
 }
}

# Create public subnets within the AWS VPC using the "aws_subnet" resource.
resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnet_cidrs)  # Create one subnet per value in public_subnet_cidrs
  vpc_id     = aws_vpc.EKS_VPC.id                   # Associate these subnets with an existing VPC
  cidr_block = element(var.public_subnet_cidrs, count.index)  # Use the CIDR block from the variable list
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet ${count.index + 1}"  # Name each subnet uniquely based on its index
  }
}

# Create private subnets within the AWS VPC using the "aws_subnet" resource.
resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnet_cidrs)  # Create one subnet per value in private_subnet_cidrs
  vpc_id     = aws_vpc.EKS_VPC.id                   # Associate these subnets with an existing VPC
  cidr_block = element(var.private_subnet_cidrs, count.index)  # Use the CIDR block from the variable list
  availability_zone = element(var.azs, count.index) # specify the zone for this subnet
  tags = {
    Name = "Private Subnet ${count.index + 1}"  # Name each subnet uniquely based on its index
  }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.EKS_VPC.id
 
 tags = {
   Name = "Project VPC IG"
 }
}

resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.EKS_VPC.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "2nd Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.second_rt.id
}