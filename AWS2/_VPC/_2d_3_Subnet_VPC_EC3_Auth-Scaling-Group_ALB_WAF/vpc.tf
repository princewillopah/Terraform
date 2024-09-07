resource "aws_vpc" "myapp-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "my_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.myapp-vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.avail_zone, count.index)
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.myapp-vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs) 
  subnet_id      = aws_subnet.my_public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}
