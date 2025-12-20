

# ---------------------------------------
# Create Public Subnets 
# ---------------------------------------
# PUBLIC SUBNETS
resource "aws_subnet" "web_public_subnet" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key


  tags = {
    Name = "web-public-subnet-${each.key}"
  }
}


# ---------------------------------------
# Create Public Route Table 
# ---------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "${var.app_name}-public-rt"
    }
}
# ---------------------------------------
# Create Public Route to Internet Gateway
# ---------------------------------------
resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}   

# ---------------------------------------
# Associate Public Subnets with Public Route Table
# ---------------------------------------

resource "aws_route_table_association" "public_subnets_assoc" {
  for_each = aws_subnet.web_public_subnet  //loop through all created public subnets

  subnet_id      = each.value.id  // fetch the subnet id of each subnet
  route_table_id = aws_route_table.public_rt.id
}

# resource "aws_route_table_association" "public_assoc_az1" {
#   subnet_id      = aws_subnet.public_subnet_az1.id
#   route_table_id = aws_route_table.public_rt.id
# }   
# resource "aws_route_table_association" "public_assoc_az2" {
#   subnet_id      = aws_subnet.public_subnet_az2.id
#   route_table_id = aws_route_table.public_rt.id
# }

