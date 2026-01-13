# Public RTs
resource "aws_route_table" "a_public_rt" {
  vpc_id = aws_vpc.vpc_a.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_a.id
  }
tags = {
    Name = "VPC_A_Public_RT"
  }

}

resource "aws_route_table" "b_public_rt" {
  vpc_id = aws_vpc.vpc_b.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_b.id
  }
tags = {
    Name = "VPC_B_Public_RT"
  }
}

resource "aws_route_table" "c_public_rt" {
  vpc_id = aws_vpc.vpc_c.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_c.id
  }
tags = {
    Name = "VPC_C_Public_RT"
  }
}

# Private RTs (no internet route) - we will modify it later to add peering routes
resource "aws_route_table" "a_private_rt" { vpc_id = aws_vpc.vpc_a.id }
resource "aws_route_table" "b_private_rt" { vpc_id = aws_vpc.vpc_b.id }
resource "aws_route_table" "c_private_rt" { vpc_id = aws_vpc.vpc_c.id }

# -------------------------------------------------------------------------------------
# Associate RTs with Subnets
# -------------------------------------------------------------------------------------
# VPC A
resource "aws_route_table_association" "a_public_rta" {
  subnet_id      = aws_subnet.a_public.id
  route_table_id = aws_route_table.a_public_rt.id
}
resource "aws_route_table_association" "a_private_rta" {
  subnet_id      = aws_subnet.a_private.id
  route_table_id = aws_route_table.a_private_rt.id
}
# VPC B
resource "aws_route_table_association" "b_public_rta" {
  subnet_id      = aws_subnet.b_public.id
  route_table_id = aws_route_table.b_public_rt.id
}
resource "aws_route_table_association" "b_private_rta" {
  subnet_id      = aws_subnet.b_private.id
  route_table_id = aws_route_table.b_private_rt.id
}
# VPC C
resource "aws_route_table_association" "c_public_rta" {
  subnet_id      = aws_subnet.c_public.id
  route_table_id = aws_route_table.c_public_rt.id
}
resource "aws_route_table_association" "c_private_rta" {
  subnet_id      = aws_subnet.c_private.id
  route_table_id = aws_route_table.c_private_rt.id
}

