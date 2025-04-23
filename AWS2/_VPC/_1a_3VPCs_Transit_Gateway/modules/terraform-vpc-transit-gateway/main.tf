# Create a Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description = "Transit Gateway for connecting VPC-A, VPC-B, and VPC-C"
 # auto_accept_shared_attachments = true
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "Transit-Gateway-for-VPC-A-VPC-B-and-VPC-C"
  }
}


# Create TGW Attachment for VPC A to Attach VPC A to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_A_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc_a_id
  subnet_ids         = var.vpc_A_subnet_ids  # Use the variable to pass subnet IDs

tags = {
    Name = "VPC-A-TransitGateway-Attachment"
  }
}

# Create TGW Attachment for VPC B to Attach VPC B to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_B_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc_b_id
#   subnet_ids         = aws_subnet.vpc2_subnets[*].id
    subnet_ids        =  var.vpc_B_subnet_ids  # Use the variable to pass subnet IDs
    tags = {
        Name = "VPC-B-TransitGateway-Attachment"
    }
}

# Create TGW Attachment for VPC C to Attach VPC C to the Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_C_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc_c_id

    subnet_ids        =  var.vpc_C_subnet_ids  
    tags = {
        Name = "VPC-C-TransitGateway-Attachment"
    }
}

# Update route table for VPC-A to route traffic to VPC-B through the Transit Gateway
resource "aws_route" "vpcA_to_vpcB" {
  route_table_id         = var.vpc_A_private_rt        # VPC-A route table ID
  destination_cidr_block = var.vpc_B_cidr_block        # Destination CIDR block for VPC-B
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.vpc_A_attachment]
}

# Update route table for VPC-A to route traffic to VPC-C through the Transit Gateway
resource "aws_route" "vpcA_to_vpcC" {
  route_table_id         = var.vpc_A_private_rt        # VPC-A route table ID
  destination_cidr_block = var.vpc_C_cidr_block        # Destination CIDR block for VPC-C
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.vpc_A_attachment]
}

# Update route table for VPC-B to route traffic to VPC-A through the Transit Gateway
resource "aws_route" "vpcB_to_vpcA" {
  route_table_id         = var.vpc_B_private_rt        # VPC-B route table ID
  destination_cidr_block = var.vpc_A_cidr_block        # Destination CIDR block for VPC-A
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.vpc_B_attachment]
}

# Update route table for VPC-B to route traffic to VPC-C through the Transit Gateway
resource "aws_route" "vpcB_to_vpcC" {
  route_table_id         = var.vpc_B_private_rt        # VPC-B route table ID
  destination_cidr_block = var.vpc_C_cidr_block        # Destination CIDR block for VPC-C
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.vpc_B_attachment]
}

# Update route table for VPC-C to route traffic to VPC-A through the Transit Gateway
resource "aws_route" "vpcC_to_vpcA" {
  route_table_id         = var.vpc_C_private_rt        # VPC-C route table ID
  destination_cidr_block = var.vpc_A_cidr_block        # Destination CIDR block for VPC-A
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.vpc_C_attachment]
}

# Update route table for VPC-C to route traffic to VPC-B through the Transit Gateway
resource "aws_route" "vpcC_to_vpcB" {
  route_table_id         = var.vpc_C_private_rt        # VPC-C route table ID
  destination_cidr_block = var.vpc_B_cidr_block        # Destination CIDR block for VPC-B
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.vpc_C_attachment]
}



# # Update route table for VPC1 to route traffic to VPC2 through Transit Gateway
# resource "aws_route" "vpcA_to_tgw" {
#   route_table_id         = aws_vpc.vpc1.main_route_table_id
#   destination_cidr_block = aws_vpc.vpc2.cidr_block
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }

# # Create Route in VPC 2 Route Table to route through TGW to VPC 1
# resource "aws_route" "vpcB_to_tgw" {
#   route_table_id         = aws_vpc.vpc2.main_route_table_id
#   destination_cidr_block = aws_vpc.vpc1.cidr_block
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }

# # Create Route in VPC 2 Route Table to route through TGW to VPC 1
# resource "aws_route" "vpcC_to_tgw" {
#   route_table_id         = aws_vpc.vpc2.main_route_table_id
#   destination_cidr_block = aws_vpc.vpc1.cidr_block
#   transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
# }



