resource "aws_subnet" "web_tier_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = { Name = "${var.app_name}-web-sub-1a" }
}

resource "aws_subnet" "web_tier_subnet_1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = { Name = "${var.app_name}-web-sub-1b" }
}

resource "aws_subnet" "app_tier_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.5.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = { Name = "${var.app_name}-app-sub-1a" }
}

resource "aws_subnet" "app_tier_subnet_1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.6.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = { Name = "${var.app_name}-app-sub-1b" }
}


resource "aws_subnet" "data_tier_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.7.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = { Name = "${var.app_name}-data-sub-1a" }
}



# ---------------------------------------------------------------------------------
# create the public route table
# ---------------------------------------------------------------------------------
resource "aws_route_table" "Private_RT" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-Private-Route-Table"
  }
}


# Elastic IP creation for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = { Name = "${var.app_name}-nat-eip" }
}


# ------------------------------------------------------
# NAT Gateway creation (aws_nat_gateway)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1a.id

  tags = { Name = "${var.app_name}-nat-gateway-main" }
}

# Insert route to private route table to point to NAT Gateway
resource "aws_route" "private_app_nat_route" {
  route_table_id         = aws_route_table.Private_RT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route Table Association for Private Subnets
resource "aws_route_table_association" "web_tier_subnet_1a_association" {
  subnet_id      = aws_subnet.web_tier_subnet_1a.id
  route_table_id = aws_route_table.Private_RT.id
}

resource "aws_route_table_association" "web_tier_subnet_1b_association" {
  subnet_id      = aws_subnet.web_tier_subnet_1b.id
  route_table_id = aws_route_table.Private_RT.id
}

resource "aws_route_table_association" "app_tier_subnet_1a_association" {
  subnet_id      = aws_subnet.app_tier_subnet_1a.id
  route_table_id = aws_route_table.Private_RT.id
}

resource "aws_route_table_association" "app_tier_subnet_1b_association" {
  subnet_id      = aws_subnet.app_tier_subnet_1b.id
  route_table_id = aws_route_table.Private_RT.id
}

resource "aws_route_table_association" "data_tier_subnet_1a_association" {
  subnet_id      = aws_subnet.data_tier_subnet_1a.id
  route_table_id = aws_route_table.Private_RT.id
}





