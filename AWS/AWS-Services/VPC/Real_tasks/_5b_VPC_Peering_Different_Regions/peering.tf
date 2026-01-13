# --------------------------------------------------------------------
# Peering Requests (Requester Side)
# -------------------------------------------------------------------
# A <-> B
resource "aws_vpc_peering_connection" "a_b" {
   provider        = aws.use1
  vpc_id      = aws_vpc.vpc_a.id
  peer_vpc_id = aws_vpc.vpc_b.id
  peer_region     = "us-west-2"

    tags = {
    Name = "VPC_Connection_A_B"
  }
}

# A <-> C
resource "aws_vpc_peering_connection" "a_c" {
  provider        = aws.use1
  vpc_id      = aws_vpc.vpc_a.id
  peer_vpc_id = aws_vpc.vpc_c.id
   peer_region     = "eu-west-1"

    tags = {
    Name = "VPC_Connection_A_C"
  }
}

# B <-> C
resource "aws_vpc_peering_connection" "b_c" {
   provider        = aws.usw2
  vpc_id      = aws_vpc.vpc_b.id
  peer_vpc_id = aws_vpc.vpc_c.id
  peer_region     = "eu-west-1"

    tags = {
    Name = "VPC_Connection_B_C"
  }
}
# -------------------------------------------------------------------
# Peering Acceptance (REQUIRED)
# -------------------------------------------------------------------
resource "aws_vpc_peering_connection_accepter" "b_accepts_a" {
  provider                  = aws.usw2
  vpc_peering_connection_id = aws_vpc_peering_connection.a_b.id
  auto_accept               = true
}

resource "aws_vpc_peering_connection_accepter" "c_accepts_a" {
  provider                  = aws.euw1
  vpc_peering_connection_id = aws_vpc_peering_connection.a_c.id
  auto_accept               = true
}

resource "aws_vpc_peering_connection_accepter" "c_accepts_b" {
  provider                  = aws.euw1
  vpc_peering_connection_id = aws_vpc_peering_connection.b_c.id
  auto_accept               = true
}


# -------------------------------------------------------------------
# Peering Public Routes 
# -------------------------------------------------------------------
# VPC-A public RT → VPC-B
resource "aws_route" "a_public_to_b" {
  provider                    = aws.use1
  route_table_id             = aws_route_table.a_public_rt.id
  destination_cidr_block     = "10.11.0.0/16"
  vpc_peering_connection_id  = aws_vpc_peering_connection.a_b.id
}


# VPC-A public RT → VPC-C
resource "aws_route" "a_public_to_c" {
   provider                    = aws.use1
  route_table_id             = aws_route_table.a_public_rt.id
  destination_cidr_block     = "10.12.0.0/16"
  vpc_peering_connection_id  = aws_vpc_peering_connection.a_c.id
}
# VPC-B public RT → VPC-A
resource "aws_route" "b_public_to_a" {
    provider                    = aws.usw2
  route_table_id             = aws_route_table.b_public_rt.id
  destination_cidr_block     = "10.10.0.0/16"
  vpc_peering_connection_id  = aws_vpc_peering_connection.a_b.id
}   
# VPC-B public RT → VPC-C
resource "aws_route" "b_public_to_c" {
    provider                    = aws.usw2
  route_table_id             = aws_route_table.b_public_rt.id
  destination_cidr_block     = "10.12.0.0/16"
  vpc_peering_connection_id  = aws_vpc_peering_connection.b_c.id
}   
# VPC-C public RT → VPC-A
resource "aws_route" "c_public_to_a" {
    provider                    = aws.euw1
  route_table_id             = aws_route_table.c_public_rt.id
  destination_cidr_block     = "10.10.0.0/16"
  vpc_peering_connection_id  = aws_vpc_peering_connection.a_c.id
}
# VPC-C public RT → VPC-B
resource "aws_route" "c_public_to_b" {
    provider                    = aws.euw1
  route_table_id             = aws_route_table.c_public_rt.id
  destination_cidr_block     = "10.11.0.0/16"
  vpc_peering_connection_id  = aws_vpc_peering_connection.b_c.id
}   



# -------------------------------------------------------------------
# Peering Private Routes (CRITICAL – no routing = no traffic)
# -------------------------------------------------------------------
# this section is modifying VPC A’s, VPC B and VPC C private route table created in route_table.tf file.

# VPC A routes
resource "aws_route" "a_to_b" {
  provider                = aws.use1
  route_table_id         = aws_route_table.a_private_rt.id
  destination_cidr_block = "10.11.0.0/16" # Entire VPC B address space(10.11.0.0 – 10.11.255.255)
  vpc_peering_connection_id = aws_vpc_peering_connection.a_b.id

}

resource "aws_route" "a_to_c" {
  provider                = aws.use1
  route_table_id         = aws_route_table.a_private_rt.id
  destination_cidr_block = "10.12.0.0/16" # Entire VPC C address space(10.12.0.0 – 10.12.255.255)
  vpc_peering_connection_id = aws_vpc_peering_connection.a_c.id
}

# VPC B routes
resource "aws_route" "b_to_a" {
  provider                = aws.usw2
  route_table_id         = aws_route_table.b_private_rt.id
  destination_cidr_block = "10.10.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.a_b.id
}

resource "aws_route" "b_to_c" {
  provider                = aws.usw2
  route_table_id         = aws_route_table.b_private_rt.id
  destination_cidr_block = "10.12.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.b_c.id
}

# VPC C routes
resource "aws_route" "c_to_a" {
  provider                = aws.euw1
  route_table_id         = aws_route_table.c_private_rt.id
  destination_cidr_block = "10.10.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.a_c.id
}

resource "aws_route" "c_to_b" {
  provider                = aws.euw1
  route_table_id         = aws_route_table.c_private_rt.id
  destination_cidr_block = "10.11.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.b_c.id
}

