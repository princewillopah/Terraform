
# Create VPC Peering connection
resource "aws_vpc_peering_connection" "peer_connection_for_vpc1_to_vpc2" {
# peer_owner_id = var.peer_owner_id  
  vpc_id        = var.vpc_1_id
  peer_vpc_id   = var.vpc_2_id
#   peer_region   = "us-west-2" # Optional, only needed if the VPCs are in different regions
#   auto_accept   = false # set true if you want the other side to auto-accept

 tags = {
    Name = "VPC1-to-VPC2-Peering-Requester"
  }
}

# Accept Peering Connection on Accepter Side from VPC2 side
resource "aws_vpc_peering_connection_accepter" "peer_accepter" {
#   provider                  = aws.accepter # Assume you have set up a provider for accepter account if needed
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection_for_vpc1_to_vpc2.id
  auto_accept               = true
#   vpc_id                    = aws_vpc.vpc2.id

   tags = {
    Name = "VPC2-Accepted-Peering"
  }
}



# Update route table for VPC1 by Adding Route to VPC 1 Route Table to allow traffic to peer VPC2
resource "aws_route" "route_vpc1_to_vpc2" {
  route_table_id            = var.vpc1_private_rt # Assume you have created a route table for VPC1
  destination_cidr_block    = var.vpc2_cidr_block  # this should be the desitination i.e cidr block of vpc2
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer_connection_for_vpc1_to_vpc2.id # peering connction from vpc 1 to vpc2
}


# Update route table for VPC2 by Add Route to VPC 2 Route Table to allow traffic to peer VPC
resource "aws_route" "route_vpc2_to_vpc1" {
  route_table_id            = var.vpc2_private_rt# Assume you have created a route table for VPC2
  destination_cidr_block    = var.vpc1_cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer_connection_for_vpc1_to_vpc2.id # peering connction from vpc 1 to vpc2 # note that the hsare the saame connection created above
}

















