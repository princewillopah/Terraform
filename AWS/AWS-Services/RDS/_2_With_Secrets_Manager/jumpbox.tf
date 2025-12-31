# create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.rds_vpc.id

  tags = {
    Name = "RDS-VPC-IGW"
  }
}
# Create public subnet
resource "aws_subnet" "rds_public_subnet" {
  vpc_id                  = aws_vpc.rds_vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "rds-public-subnet-a"
  }
}
# Create route table
resource "aws_route_table" "rds_public_route_table" {
  vpc_id = aws_vpc.rds_vpc.id
  tags = {
    Name = "rds-public-route-table"
  }
}
# Create route to Internet Gateway
resource "aws_route" "rds_public_route" {
  route_table_id         = aws_route_table.rds_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
} 
# Associate subnet with route table
resource "aws_route_table_association" "rds_public_subnet_association" {
  subnet_id      = aws_subnet.rds_public_subnet.id
  route_table_id = aws_route_table.rds_public_route_table.id
}



# create a jumpbox EC2 instance in the public subnet
resource "aws_instance" "jumpbox" {
  ami                         = "ami-0ecb62995f68bb549" # for us-east-1
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.rds_public_subnet.id
  vpc_security_group_ids    = [aws_security_group.jumpbox-security-group.id]
  associate_public_ip_address = true
  key_name                    = var.key_name  # make sure to create/import this key in AWS
  user_data = templatefile("./tools-install.sh", {})
  tags = {
    Name = "rds-jumpbox"
  }
    # provisioner "remote-exec" {
    #   inline = [
    #     "sudo apt update -y",
    #     "sudo apt install -y mysql-client"
    #   ]
    #   connection {
    #     type        = "ssh"
    #     user        = "ubuntu"
    #     private_key = file(var.private_key_path)
    #     host        = self.public_ip
    #   }
    # }
}


# create security group for jumpbox
resource "aws_security_group" "jumpbox-security-group" {
  name        = "jumpbox-security-group"
  description = "Allow SSH and MySQL access"
  vpc_id      = aws_vpc.rds_vpc.id  

    ingress {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.my_ip]  # restrict to your IP
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}