resource "aws_vpc" "vpc_a" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "VPC-A" }
}

resource "aws_vpc" "vpc_b" {
  cidr_block           = "10.11.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "VPC-B" }
}

resource "aws_vpc" "vpc_c" {
  cidr_block           = "10.12.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "VPC-C" }
}
