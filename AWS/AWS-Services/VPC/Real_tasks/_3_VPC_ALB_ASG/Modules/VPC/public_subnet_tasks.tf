

# ---------------------------------------
# Create Public Subnets 
# ---------------------------------------
resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets_vars

  vpc_id                  = aws_vpc.app_vpc.id
  availability_zone       = each.value.az
  cidr_block              = cidrsubnet(var.vpc_CIDR, 8, each.value.cidr_index)  
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-public-${each.key}"
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
  for_each = aws_subnet.public_subnets  //loop through all created public subnets

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

