# PUBLIC SUBNETS
resource "aws_subnet" "web_public_subnet1a" {
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = "10.5.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "web-public-subnet-1a" }
}

resource "aws_subnet" "web_public_subnet1b" {
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = "10.5.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = { Name = "web-public-subnet-1b" }
}



# PRIVATE APP SUBNETS
resource "aws_subnet" "app_private_subnet1a" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.2.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "app_private_subnet1a" }
}

resource "aws_subnet" "app_private_subnet1b" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.5.0/24"
  availability_zone = "us-east-1b"

  tags = { Name = "app_private_subnet1b" }
}




# PRIVATE DATA SUBNETS
resource "aws_subnet" "data_private_subnet1a" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.3.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "data_private_subnet1a" }
}

resource "aws_subnet" "data_private_subnet1b" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.6.0/24"
  availability_zone = "us-east-1b"

  tags = { Name = "data_private_subnet1b" }
}

