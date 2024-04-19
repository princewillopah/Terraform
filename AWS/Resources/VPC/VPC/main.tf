

resource "aws_vpc" "my-vpc" {
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
  vpc_id     = aws_vpc.my-vpc.id                   # Associate these subnets with an existing VPC
  cidr_block = element(var.public_subnet_cidrs, count.index)  # Use the CIDR block from the variable list
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "Public Subnet ${count.index + 1}"  # Name each subnet uniquely based on its index
  }
}

# Create private subnets within the AWS VPC using the "aws_subnet" resource.
resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnet_cidrs)  # Create one subnet per value in private_subnet_cidrs
  vpc_id     = aws_vpc.my-vpc.id                   # Associate these subnets with an existing VPC
  cidr_block = element(var.private_subnet_cidrs, count.index)  # Use the CIDR block from the variable list
  availability_zone = element(var.azs, count.index) # specify the zone for this subnet
  tags = {
    Name = "Private Subnet ${count.index + 1}"  # Name each subnet uniquely based on its index
  }
}

//-----------------------------------------------------
// public route table
//----------------------------------------------------
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.my-vpc.id
 
 tags = {
   Name = "${var.environment}-VPC-IGW"
 }
}

resource "aws_route_table" "Public_Route_Table" {
 vpc_id = aws_vpc.my-vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "Public Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.Public_Route_Table.id
}


//-----------------------------------------------------
// private route table
//----------------------------------------------------

# Create a private route table
resource "aws_route_table" "Private_Route_Table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = aws_vpc.my-vpc.cidr_block  # # Local route within the VPC //  cidr_block =  "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "Private Route Table"
  }
}



# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.Private_Route_Table.id
}