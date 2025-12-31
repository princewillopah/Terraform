resource "aws_subnet" "jumpbox_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.9.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "${var.app_name}-jumpbox-sub" }
}



resource "aws_route_table" "jumpbox_RT" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-Jumpbox-Route-Table"
  }
}


resource "aws_route" "jumpbox_internet" {
  route_table_id         = aws_route_table.jumpbox_RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route Table Association for Jumpbox Subnets

resource "aws_route_table_association" "jumpbox_subnet_association" {
  subnet_id      = aws_subnet.jumpbox_subnet.id
  route_table_id = aws_route_table.jumpbox_RT.id
}


