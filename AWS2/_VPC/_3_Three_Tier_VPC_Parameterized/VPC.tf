provider "aws" {
  region = "eu-north-1"
}

//-----------------------------------------------------
// variables
//----------------------------------------------------

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "my_private_ip" {
  default = "192.168.167.30"
}
//-----------------------------------------------------
// look for azs in your regions
//----------------------------------------------------
data "aws_availability_zones" "available" {}

//-----------------------------------------------------
// VPC
//----------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

//-----------------------------------------------------
// PUBLIC/PRIVATE subnets
//----------------------------------------------------

resource "aws_subnet" "public" {
  count       = length(var.public_subnet_cidr_blocks)  #3
  vpc_id      = aws_vpc.main.id
  cidr_block  = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count       = length(var.private_subnet_cidr_blocks)
  vpc_id      = aws_vpc.main.id
  cidr_block  = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

//-----------------------------------------------------
// internet Gateway
//----------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

//-----------------------------------------------------
// Elastic IP and Nat Gateway
//----------------------------------------------------
resource "aws_eip" "nat" {  # create 3 elastic ip
  count = length(aws_subnet.public)  # 3
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {  # create 3 nat gateway in the 3 public subnet
  count = length(aws_subnet.public)  # 3
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}

//-----------------------------------------------------
// Route Table, attched IGW
//----------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id            = aws_internet_gateway.main.id
  }
}

//-----------------------------------------------------
// handl 3 private route table for 
//----------------------------------------------------
resource "aws_route_table" "private" {
  # vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   nat_gateway_id        = aws_nat_gateway.main[count.index].id
  # }

  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }
}

//-----------------------------------------------------
// associate the 3 public subnets to the public route table
//----------------------------------------------------
resource "aws_route_table_association" "public" {
  count       = length(aws_subnet.public)
  subnet_id   = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

//-----------------------------------------------------
// associate the 3 private route tables to individual subnet
//----------------------------------------------------
# resource "aws_route_table_association" "private" {
#   count       = length(aws_subnet.private)
#   subnet_id   = element(aws_subnet.private.*.id, count.index)
#   route_table_id = aws_route_table.private.id
# }
resource "aws_route_table_association" "private" {
  count         = length(aws_subnet.private)
  subnet_id     = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[count.index].id
}

//-----------------------------------------------------
// SG
//----------------------------------------------------
resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description         = "Allow SSH"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    cidr_blocks         = ["${var.my_private_ip}/32"]
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
