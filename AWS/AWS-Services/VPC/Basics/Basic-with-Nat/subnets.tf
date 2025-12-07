# PUBLIC SUBNETS
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = "10.5.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "public-sub-1a" }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = "10.5.6.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = { Name = "public-sub-1b" }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.three_tier.id
  cidr_block              = "10.5.9.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = { Name = "public-sub-1c" }
}


# PRIVATE APP SUBNETS
resource "aws_subnet" "private_app_1a" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.4.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "private-app-sub-1a" }
}

resource "aws_subnet" "private_app_1b" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.7.0/24"
  availability_zone = "us-east-1b"

  tags = { Name = "private-app-sub-1b" }
}

resource "aws_subnet" "private_app_1c" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.10.0/24"
  availability_zone = "us-east-1c"

  tags = { Name = "private-app-sub-1c" }
}


# PRIVATE DATA SUBNETS
resource "aws_subnet" "private_data_1a" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.5.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "private-data-sub-1a" }
}

resource "aws_subnet" "private_data_1b" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.8.0/24"
  availability_zone = "us-east-1b"

  tags = { Name = "private-data-sub-1b" }
}

resource "aws_subnet" "private_data_1c" {
  vpc_id            = aws_vpc.three_tier.id
  cidr_block        = "10.5.11.0/24"
  availability_zone = "us-east-1c"

  tags = { Name = "private-data-sub-1c" }
}
