resource "aws_vpc" "main" { # # VPC-C
  cidr_block              = var.vpc_cidr

  tags = {
    Name = "${var.environment}-VPC-C"
  }
}

resource "aws_subnet" "private_subnet" { 
  vpc_id                  = aws_vpc.main.id
   cidr_block        = var.private_subnet_cidr 

   tags              ={ 
      Name          ="${var.environment}-VPC-C-private-subnet"
   }
}

resource "aws_route_table" "private_rt" {
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-VPC-C-public-rt"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}



resource "aws_security_group" "private_sg" { 
  vpc_id                  = aws_vpc.main.id

   ingress { 
      from_port       =22 # SSH access.
      to_port         =22 
      protocol        ="tcp"
      cidr_blocks = ["10.1.0.0/16","10.2.0.0/16"] # Allow SSH from the public subnet only.
  }
# 10.2.0.0/16
ingress {
    description      = "Allow ICMP - ping"
    from_port        = -1                  # For ICMP, from_port and to_port are -1
    to_port          = -1
    protocol         = "icmp"              # Protocol for ICMP
    cidr_blocks      = ["10.1.0.0/16","10.2.0.0/16"] # Only allow ICMP from the public EC2 instance's IP or a specific range
}
   egress { 
      from_port       =0 
      to_port         =0 
      protocol        ="-1"
      cidr_blocks     =["0.0.0.0/0"]
   }

   tags ={ 
      Name          ="${var.environment}-VPC-C-private-sg"
   }
}

resource "aws_instance" "private_instance" { 
   ami           = var.ec2_ami # You need to specify a valid AMI ID.
   instance_type = var.instance_type
  subnet_id         =(aws_subnet.private_subnet.id) 
  security_groups =[aws_security_group.private_sg.id]
  key_name      = var.key_name

   # user_data = file("install.sh") 
   tags ={ 
         Name          ="${var.environment}-VPC-C-private-instance"
   }
}

