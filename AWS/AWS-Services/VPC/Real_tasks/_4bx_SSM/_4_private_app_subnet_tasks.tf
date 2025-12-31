# PRIVATE APP SUBNETS
resource "aws_subnet" "private_app_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.5.2.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "${var.app_name}-Private-Subnet" }
}

# Elastic IP creation for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "${var.app_name}-nat-eip" }
}

# What it does:
# - Allocates a static public IP in AWS.
# - domain = "vpc" means the EIP is intended for use in a VPC (not EC2-Classic).
# - This EIP will later be attached to the NAT Gateway.



# ------------------------------------------------------
# NAT Gateway creation (aws_nat_gateway)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1a.id

  tags = { Name = "${var.app_name}-nat-gateway" }
}
# What it does:
# - Creates a managed NAT Gateway inside a public subnet (public_1a).
# - allocation_id links the NAT Gateway to the EIP you just created.
# - The NAT Gateway provides outbound internet access for private subnets while keeping the private instances inaccessible from the internet.


# Why NAT must be in a public subnet
# A NAT Gateway needs:
# - A public IP address (EIP)
# - A route to the internet through the Internet Gateway. This is only possible in a public subnet.


# ---------------------------------------------------------------------------------
# create the private route table
# ---------------------------------------------------------------------------------
resource "aws_route_table" "private_app_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-Private--App-Route-Table"
  }
}


resource "aws_route" "private_app_nat_route" {
  route_table_id         = aws_route_table.private_app_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# --------------------------------------------------------------------------
# Associate subnet to route table
# --------------------------------------------------------------------------
resource "aws_route_table_association" "pvt_app_1a_assoc" {
  subnet_id      = aws_subnet.private_app_1a.id
  route_table_id = aws_route_table.private_app_rt.id
}
