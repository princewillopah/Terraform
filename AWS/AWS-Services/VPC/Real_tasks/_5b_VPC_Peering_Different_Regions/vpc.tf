resource "aws_vpc" "vpc_a" {
  provider               = aws.use1 # US East (N. Virginia)
  cidr_block             = "10.10.0.0/16"
  enable_dns_support     = true
  enable_dns_hostnames   = true
  tags = { Name = "VPC-A-us-east-1" }
}

resource "aws_vpc" "vpc_b" {
  provider               = aws.usw2 # US West (Oregon)
  cidr_block             = "10.11.0.0/16"
  enable_dns_support     = true
  enable_dns_hostnames   = true
  tags = { Name = "VPC-B-us-west-2" }
}

resource "aws_vpc" "vpc_c" {
  provider               = aws.euw1 # EU West (Ireland)
  cidr_block             = "10.12.0.0/16"
  enable_dns_support     = true
  enable_dns_hostnames   = true
  tags = { Name = "VPC-C-eu-west-1" }
}
