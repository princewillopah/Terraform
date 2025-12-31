resource "aws_subnet" "rds_subnet_a" {
  vpc_id                  = aws_vpc.rds_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false # default = false
  tags = {
    Name = "rds-subnet-a"
  }
}

resource "aws_subnet" "rds_subnet_b" {
  vpc_id                  = aws_vpc.rds_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "rds-subnet-b"
  }
}

# this will use default route table created with VPC
# to create custom route table, uncomment below code
# resource "aws_route_table" "rds_route_table" {
#   vpc_id = aws_vpc.rds_vpc.id
#   tags = {
#     Name = "rds-route-table"
#   }
# } 

# associate subnets with route table
# resource "aws_route_table_association" "rds_subnet_a_association" {
#   subnet_id      = aws_subnet.rds_subnet_a.id
#   route_table_id = aws_route_table.rds_route_table.id
# }
# resource "aws_route_table_association" "rds_subnet_b_association" {
#   subnet_id      = aws_subnet.rds_subnet_b.id
#   route_table_id = aws_route_table.rds_route_table.id
# }


## --------------------------------------------------------------------------------------------------------------------------------------------------
## DB Subnet Group (REQUIRED for VPC deployment)
## --------------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-mysql-subnet-group"

  subnet_ids = [aws_subnet.rds_subnet_a.id, aws_subnet.rds_subnet_b.id]

  description = "Subnet group for MySQL RDS"
  tags = { Name = "rds-subnet-group" }
}





## --------------------------------------------------------------------------------------------------------------------------------------------------
## END OF FILE
## --------------------------------------------------------------------------------------------------------------------------------------------------   
