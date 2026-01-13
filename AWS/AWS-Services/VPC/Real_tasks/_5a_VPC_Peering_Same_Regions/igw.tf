resource "aws_internet_gateway" "igw_a" {
  vpc_id = aws_vpc.vpc_a.id
}

resource "aws_internet_gateway" "igw_b" {
  vpc_id = aws_vpc.vpc_b.id
}

resource "aws_internet_gateway" "igw_c" {
  vpc_id = aws_vpc.vpc_c.id
}
