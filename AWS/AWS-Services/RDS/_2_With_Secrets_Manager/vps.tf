resource "aws_vpc" "rds_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true  # default = true
  enable_dns_hostnames = true  # default = false (we explicitly enable)
  tags = {
    Name = "rds-vpc"
  }
}


