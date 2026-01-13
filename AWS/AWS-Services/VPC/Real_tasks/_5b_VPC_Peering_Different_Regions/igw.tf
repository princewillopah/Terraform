resource "aws_internet_gateway" "igw_a" {
  provider = aws.use1
  vpc_id  = aws_vpc.vpc_a.id
}

resource "aws_internet_gateway" "igw_b" {
  provider = aws.usw2
  vpc_id  = aws_vpc.vpc_b.id
}

resource "aws_internet_gateway" "igw_c" {
  provider = aws.euw1
  vpc_id  = aws_vpc.vpc_c.id
}
