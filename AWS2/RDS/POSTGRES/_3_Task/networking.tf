###############################################################################
# NETWORKING
#
# Architecture:
#
#   Internet
#      │
#   Internet Gateway
#      │
#   Public Subnets   ← Bastion Host lives here (has a public IP)
#      │
#   NAT Gateway      ← Lets private resources reach the internet (e.g. OS updates)
#      │
#   Private Subnets  ← RDS + App EC2 live here (NO public IP)
#
# Why private subnets for RDS?
#   The database should NEVER be directly reachable from the internet.
#   Only resources inside the VPC (your app, your bastion) can talk to it.
###############################################################################

# ─── VPC ─────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true   # Required for RDS hostnames to resolve
  enable_dns_hostnames = true   # Required for RDS hostnames to resolve

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# # ─── Internet Gateway ────────────────────────────────────────────────────────
# # Allows resources in PUBLIC subnets to reach the internet

# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name        = "${var.project_name}-igw"
#     Environment = var.environment
#   }
# }

# # ─── Subnets ─────────────────────────────────────────────────────────────────
# # We create 2 of each (public + private) across 2 AZs.
# # RDS requires subnets in at least 2 AZs even for a single-AZ instance.

# resource "aws_subnet" "public" {
#   count             = 2
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)       # 10.0.0.0/24, 10.0.1.0/24
#   availability_zone = data.aws_availability_zones.available.names[count.index]

#   # Instances launched here automatically get a public IP
#   map_public_ip_on_launch = true

#   tags = {
#     Name        = "${var.project_name}-public-${count.index + 1}" # +1 to start from 1 instead of 0
#     Environment = var.environment
#     Tier        = "public"
#   }
# }

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)  #  10.0.0.0/24, 10.0.1.0/24
  availability_zone = data.aws_availability_zones.available.names[count.index]

  # NO public IP for private subnets
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-private-${count.index + 1}" # +1 to start from 1 instead of 0
    Environment = var.environment
    Tier        = "private"
  }
}

#@ ─── NAT Gateway ─────────────────────────────────────────────────────────────
## Allows instances in PRIVATE subnets to reach the internet (for updates etc.)
## but the internet CANNOT initiate connections back in.

# resource "aws_eip" "nat" {
#   domain = "vpc"

#   tags = {
#     Name        = "${var.project_name}-nat-eip"
#     Environment = var.environment
#   }
# }

# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public[0].id   # NAT sits in a public subnet

#   tags = {
#     Name        = "${var.project_name}-nat"
#     Environment = var.environment
#   }

#   depends_on = [aws_internet_gateway.main]
# }

# # ─── Route Tables ─────────────────────────────────────────────────────────────

# # Public route table: 0.0.0.0/0 → Internet Gateway
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }

#   tags = {
#     Name        = "${var.project_name}-public-rt"
#     Environment = var.environment
#   }
# }

# resource "aws_route_table_association" "public" {
#   count          = 2
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public.id
# }

# Private route table: 0.0.0.0/0 → NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.main.id
  # }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}
# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
