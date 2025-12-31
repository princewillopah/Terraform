# PRIVATE DATA SUBNETS
resource "aws_subnet" "private_data_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.5.3.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "${var.app_name}-Private-Subnet" }
}


# ---------------------------------------------------------------------------------
# create the private route table
# ---------------------------------------------------------------------------------
resource "aws_route_table" "private_data_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-Private-Route-Table"
  }
}

# --------------------------------------------------------------------------
# Associate subnet to route table
# --------------------------------------------------------------------------
resource "aws_route_table_association" "pvt_data_1a_assoc" {
  subnet_id      = aws_subnet.private_data_1a.id
  route_table_id = aws_route_table.private_data_rt.id
}
