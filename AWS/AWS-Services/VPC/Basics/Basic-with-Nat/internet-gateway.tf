resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.three_tier.id

  tags = {
    Name = "Three-Tier-VPC-IGW"
  }
}
