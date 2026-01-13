# VPC A
resource "aws_subnet" "a_public" {
  provider                = aws.use1
  vpc_id                  = aws_vpc.vpc_a.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}


resource "aws_subnet" "a_private" {
  provider          = aws.use1
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-1a"
    tags = {
    Name = "VPC_A_Private_Subnet"
  }
}

# VPC B
resource "aws_subnet" "b_public" {
  provider                = aws.usw2
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = "10.11.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
    tags = {
    Name = "VPC_B_Public_Subnet"
  }
}

resource "aws_subnet" "b_private" {
  provider          = aws.usw2
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = "10.11.2.0/24"
  availability_zone = "us-west-2a"
    tags = {
    Name = "VPC_B_Private_Subnet"
  }
}

# VPC C
resource "aws_subnet" "c_public" {
  provider                = aws.euw1
  vpc_id                  = aws_vpc.vpc_c.id
  cidr_block              = "10.12.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
    tags = {
    Name = "VPC_C_Public_Subnet"
  }
}

resource "aws_subnet" "c_private" {
  provider          = aws.euw1
  vpc_id            = aws_vpc.vpc_c.id
  cidr_block        = "10.12.2.0/24"
  availability_zone = "eu-west-1a"
    tags = {
    Name = "VPC_C_Private_Subnet"
  }
}
