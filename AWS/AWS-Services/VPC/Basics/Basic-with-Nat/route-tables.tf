
# =======================================================================================
# configuration for public subnets
# =======================================================================================
# ---------------------------------------------------------------------------------
# create the public route table
# ---------------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "Three-Tier-VPC-Public-Route-Table"
  }
}
# ----------------------------------------------------------------------------
# we are creating a rule for the public subnet route table
# ------------------------------------------------------------------------------
# “We are adding a rule to the public subnet’s map that says:
# For any traffic going anywhere on the internet, send it out through the Internet Gateway.
# Without this rule, servers in the public subnet cannot reach the internet.”
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}





# =======================================================================================
# configuration for private subnets
# =======================================================================================

# ---------------------------------------------------------------------------------
# create the private route table
# ---------------------------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "Three-Tier-VPC-Private-Route-Table"
  }
}


resource "aws_route" "private_app_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}



