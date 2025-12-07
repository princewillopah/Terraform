
locals {
  az_count = length(var.azs)
}
# ----------------------------
# VPC
# ----------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}
# ----------------------------
# INTERNET GATEWAY
# ----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

# ----------------------------
# PUBLIC SUBNETS
# ----------------------------
resource "aws_subnet" "public" {
  for_each = { for idx, az in var.azs : idx => az }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr, var.public_subnet_bits, each.key)
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.name}-public-${each.value}"
    Tier = "public"
  })
}

# create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}
# configure route for internet gateway
resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# associate public subnets with public route table
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ----------------------------
# NAT GATEWAYS (APP ONLY)
# ----------------------------
resource "aws_eip" "nat" {
  count = var.create_nat_per_az ? local.az_count : 1

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip-${count.index}"
  })
}

resource "aws_nat_gateway" "nat" {
  count         = var.create_nat_per_az ? local.az_count : 1
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(values(aws_subnet.public)[*].id, count.index)

  tags = merge(var.tags, {
    Name = "${var.name}-nat-${count.index}"
  })

  depends_on = [aws_internet_gateway.igw]
}

# ----------------------------
# APP SUBNETS
# ----------------------------
resource "aws_subnet" "app" {
  for_each = { for idx, az in var.azs : idx => az }

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr, var.app_subnet_bits, each.key + 100)
  availability_zone = each.value

  tags = merge(var.tags, {
    Name = "${var.name}-app-${each.value}"
    Tier = "app"
  })
}

resource "aws_route_table" "app" {
  for_each = aws_subnet.app

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-app-rt-${each.key}"
  })
}

resource "aws_route" "app_nat" {
  for_each = aws_route_table.app

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.create_nat_per_az ? aws_nat_gateway.nat[tonumber(each.key)].id : aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "app_assoc" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.app[each.key].id
}

# ----------------------------
# DATA SUBNETS (ISOLATED)
# ----------------------------
resource "aws_subnet" "data" {
  for_each = { for idx, az in var.azs : idx => az }

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.cidr, var.data_subnet_bits, each.key + 200)
  availability_zone = each.value

  tags = merge(var.tags, {
    Name = "${var.name}-data-${each.value}"
    Tier = "data"
  })
}

resource "aws_route_table" "data" {
  for_each = aws_subnet.data

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-data-rt-${each.key}"
  })
}

resource "aws_route_table_association" "data_assoc" {
  for_each = aws_subnet.data

  subnet_id      = each.value.id
  route_table_id = aws_route_table.data[each.key].id
}
