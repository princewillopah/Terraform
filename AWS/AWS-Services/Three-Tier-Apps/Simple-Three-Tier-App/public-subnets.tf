resource "aws_subnet" "public_subnet_1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "${var.app_name}-public-sub-1a" }
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = { Name = "${var.app_name}-public-sub-1b" }
}


resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-Public-Route-Table"
  }
}


resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.Public_RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route Table Association for Public Subnets

resource "aws_route_table_association" "public_subnet_1a_association" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table_association" "public_subnet_1b_association" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.Public_RT.id
}