# ---------------------------------------
# Create VPC
# ---------------------------------------
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_CIDR
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-VPC"
  }
}


# ---------------------------------------
# Create Internet Gateway
# ---------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "${var.app_name}-igw"
    }
}