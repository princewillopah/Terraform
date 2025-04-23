resource "aws_vpc" "main" { ## VPC 1 (Requester VPC)
  cidr_block              = var.vpc_cidr
  enable_dns_support      = true
  enable_dns_hostnames    = true

  tags = {
    Name = "${var.environment}-VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id                  = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "public_sg" {
  vpc_id                  = aws_vpc.main.id

   ingress {
     from_port   = 22 # SSH access.
     to_port     = 22 
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port   = 0 
     to_port     = 0 
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name        = "${var.environment}-public-sg"
   }
}

resource "aws_instance" "public_instance" {
   ami              = var.ec2_ami # You need to specify a valid AMI ID.
   instance_type    = var.instance_type 
   subnet_id        = aws_subnet.public_subnet.id 
   security_groups  = [aws_security_group.public_sg.id]
   key_name         = var.key_name
   associate_public_ip_address    = true 
  iam_instance_profile = var.ssm_instance_profile
  #  user_data = file("install.sh") 
# Set custom hostname using cloud-init in user_data
   user_data = <<-EOF
    #cloud-config
    hostname: Consumer-Public-Instance
    fqdn: Consumer-Public-Instance.example.com
    manage_etc_hosts: true
  EOF

   tags = {
      Name        ="${var.environment}-public-instance"
   }
}

# ==============================================================
# for Private
# ==============================================================

resource "aws_subnet" "private_subnet" { 
  vpc_id                  = aws_vpc.main.id
   cidr_block        = var.private_subnet_cidr 

   tags              ={ 
      Name          ="${var.environment}-private-subnet"
   }
}



resource "aws_route_table" "private_rt" {
  vpc_id                  = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "private_sg" { 
  vpc_id                  = aws_vpc.main.id

   ingress { 
      from_port       =22 # SSH access.
      to_port         =22 
      protocol        ="tcp"
      cidr_blocks = ["10.0.0.0/16"] # Allow SSH from the public subnet only.
  }

ingress {
    description      = "Allow ICMP - ping"
    from_port        = -1                  # For ICMP, from_port and to_port are -1
    to_port          = -1
    protocol         = "icmp"              # Protocol for ICMP
    cidr_blocks      = ["10.0.0.0/16"] # Only allow ICMP from the public EC2 instance's IP or a specific range
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
   ami           = var.ec2_ami # You need to specify a valid AMI ID.
   instance_type = var.instance_type
  subnet_id         =(aws_subnet.private_subnet.id) 
  security_groups =[aws_security_group.private_sg.id]
  key_name      = var.key_name
  iam_instance_profile = var.ssm_instance_profile
  #  user_data = file("hostname.sh") 
  # Set custom hostname using cloud-init in user_data
   user_data = <<-EOF
    #cloud-config
    hostname: Consumer-Private-Instance
    fqdn: Consumer-Private-Instance.example.com
    manage_etc_hosts: true
  EOF
   tags ={ 
         Name          ="${var.environment}-private-instance"
   }
}


