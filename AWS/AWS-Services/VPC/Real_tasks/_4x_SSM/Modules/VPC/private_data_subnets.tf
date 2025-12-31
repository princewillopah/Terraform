resource "aws_subnet" "private_data_subnet" {
  for_each = var.private_data_subnets

  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "web-public-subnet-${each.key}"
  }
}

# ---------------------------------------------------
# Private Route Tables (one per private subnet/AZ)
# ---------------------------------------------------
resource "aws_route_table" "private_data_rt" {
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "${var.app_name}-private-data-rt"
    }
} 
  
#NO NAT GATEWAY FOR DATA SUBNETS
# ---------------------------------------------------
# Associate Private Subnets with Private Route Tables
# ---------------------------------------------------
resource "aws_route_table_association" "private_data_subnets_assoc" {
  for_each = aws_subnet.private_data_subnet  //loop through all created private subnets
    subnet_id      = each.value.id  // fetch the subnet id of each subnet
    route_table_id = aws_route_table.private_data_rt.id
}

