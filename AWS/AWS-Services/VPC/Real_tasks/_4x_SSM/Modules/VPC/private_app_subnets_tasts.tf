# ---------------------------------------
# Create Private Subnets
# ---------------------------------------
resource "aws_subnet" "private_app_subnet" {
  for_each = var.private_app_subnets

  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key


  tags = {
    Name = "web-public-subnet-${each.key}"
  }
}

# ---------------------------------------------------
# Private Route Tables (one per private subnet/AZ)
# ---------------------------------------------------
resource "aws_route_table" "private_app_rt" {
  for_each = var.private_app_subnets
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "${var.app_name}-private-app-rt-${each.key}"
    }
}



# ---------------------------------------------------
# EIP for NAT Gateways (one per private subnet AZ)
# ---------------------------------------------------
resource "aws_eip" "nat_eip" {
  for_each = var.private_app_subnets
  domain   = "vpc"

  tags = {
    Name = "${var.app_name}-nat-eip-${each.key}"
  }
}



# ---------------------------------------------------
# NAT Gateways (Highly Available — one per AZ)
# ---------------------------------------------------
resource "aws_nat_gateway" "nat" {
  for_each = var.private_app_subnets

  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = aws_subnet.web_public_subnet[each.key].id

  tags = {
    Name = "${var.app_name}-nat-${each.key}"
  }
}

# ---------------------------------------------------
# Private Route: send all outbound traffic to NAT
# ---------------------------------------------------

resource "aws_route" "private_app_nat_route" {
  for_each = aws_route_table.private_app_rt

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

### originally written as

# resource "aws_route" "private_nat_route" {
#   for_each = var.private_app_subnets_vars

#   route_table_id         = aws_route_table.private_rt[each.key].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat[each.key].id
# }


# ---------------------------------------------------
# Associate Private Subnets with Private Route Tables
# ---------------------------------------------------
resource "aws_route_table_association" "private_subnets_assoc" {
  for_each = aws_subnet.private_app_subnet  //loop through all created private subnets
    
    subnet_id      = each.value.id  // or aws_subnet.private_subnets[each.key].id  // fetch the subnet id of each subnet   
    route_table_id = aws_route_table.private_app_rt[each.key].id
}


