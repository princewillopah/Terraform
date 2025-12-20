# PUBLIC SUBNETS
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.5.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "${var.app_name}-Public-Subnet" }
}

# ---------------------------------------------------------------------------------
# create the public route table
# ---------------------------------------------------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-Public-Route-Table"
  }
}
# ----------------------------------------------------------------------------
# we are creating a rule for the public subnet route table
# ------------------------------------------------------------------------------
# “We are adding a rule to the public subnet’s map that says:
# For any traffic going anywhere on the internet, send it out through the Internet Gateway.
# Without this rule, servers in the public subnet cannot reach the internet.”
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}


# --------------------------------------------------------------------------
# Associate subnet to route table
# --------------------------------------------------------------------------
resource "aws_route_table_association" "public_web_1a_assoc" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_rt.id
}





