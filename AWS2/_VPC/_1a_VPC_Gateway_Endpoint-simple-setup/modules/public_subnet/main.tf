resource "aws_subnet" "public_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

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
   vpc_id      = var.vpc_id

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
   ami           = var.public_ami # You need to specify a valid AMI ID.
   instance_type = var.instance_type 
   subnet_id     = aws_subnet.public_subnet.id 
   security_groups= [aws_security_group.public_sg.id]
   key_name      = var.key_name
   associate_public_ip_address    = true 
# Associate the instance profile with the existing instance
  # iam_instance_profile = var.s3_access_instance_profile_name

   user_data = file("install.sh") 


   tags = {
      Name        ="${var.environment}-public-instance"
   }
}

# output "public_instance_ip" {
#    value       = aws_instance.public_instance.public_ip 
# }