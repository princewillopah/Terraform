resource "aws_subnet" "private_subnet" { 
   vpc_id            = var.vpc_id 
   cidr_block        = var.private_subnet_cidr 

   tags              ={ 
      Name          ="${var.environment}-private-subnet"
   }
}


# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main.id
#   }
# }
## Route Table for the Private Subnet:
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-private-route-table"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# resource "aws_route" "private_subnet_route" {
#   route_table_id         = aws_route_table.private_route_table.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nat.id  # Assuming you have a NAT Gateway set up
# }

resource "aws_route" "private_subnet_internet_access" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = module.public_subnet.nat_gateway_id  # Reference from public subnet module in output of public_subnet dir
   nat_gateway_id  = var.nat_gateway_id 
}

resource "aws_security_group" "private_sg" { 
   vpc_id          =(var.vpc_id)

   ingress { 
      from_port       =22 # SSH access.
      to_port         =22 
      protocol        ="tcp"
      # cidr_blocks     =[aws_security_group.public_sg.ingress[0].cidr_blocks[0]] # Allow SSH from the public subnet only.
       cidr_blocks = ["10.0.1.0/24"] # Allow SSH from the public subnet only.
  }

ingress {
    description      = "Allow ICMP - ping"
    from_port        = -1                  # For ICMP, from_port and to_port are -1
    to_port          = -1
    protocol         = "icmp"              # Protocol for ICMP
    cidr_blocks      = ["10.0.1.0/24"] # Only allow ICMP from the public EC2 instance's IP or a specific range
}
   egress { 
      from_port       =0 
      to_port         =0 
      protocol        ="-1"
      cidr_blocks     =["0.0.0.0/0"]
   }

   tags ={ 
      Name          ="${var.environment}-private-sg"
   }
}

resource "aws_instance" "private_instance" { 
   ami           =(var.private_ami) # You need to specify a valid AMI ID.
   instance_type =(var.instance_type)
  subnet_id         =(aws_subnet.private_subnet.id) 
  security_groups =[aws_security_group.private_sg.id]
  key_name      = var.key_name

   # user_data = file("install.sh") 
   tags ={ 
         Name          ="${var.environment}-private-instance"
   }
}

