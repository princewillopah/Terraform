# terraform
# Configure the AWS Provider
# provider "aws" {
#   region = "us-west-2"
# }

# # Create RDS instance
# resource "aws_db_instance" "my_rds" {
#   allocated_storage    = 20
#   engine               = "mysql"
#   engine_version       = "8.0.21"
#   instance_class       = "db.t2.micro"
#   name                 = "mydb"
#   username             = "admin"
#   password             = "password123"
#   parameter_group_name = "default.mysql8.0"
#   skip_final_snapshot  = true
#   publicly_accessible  = true
#   vpc_security_group_ids = [(link unavailable)]
# }

# # Create security group for RDS
# resource "aws_security_group" "rds_sg" {
#   name        = "rds_sg"
#   description = "Security group for RDS"

#   # Allow inbound traffic on port 3306 (MySQL)
#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1" # Change to your preferred AWS region
}

resource "aws_db_instance" "rds_instance" {
  allocated_storage       = var.db_allocated_storage
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  db_name                    = "mydatabase"           # Database name
  username                = var.db_username                # Master username
  password                = var.db_password # Replace with your password or use AWS Secrets Manager for security
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  publicly_accessible  = true
#   publicly_accessible     = false  # Set to true if you want public access
# 
  multi_az                = false
  identifier                = "dev-rds-instance"
    # db_subnet_group_name = xxx.xxx.xxx
    # availability_zone  =  xxx.xxx.xx 
    # vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  tags = {
        Name        = "MyRDSInstance"
        Environment = "dev"
        Owner       = "Princewill"
    }
}

# Security group allowing access to the RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "allow-rds-access"
  description = "Allow MySQL traffic"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Limit this for security, replace with specific CIDR/IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   # Adding tags
  tags = {
    Name        = "RDS-Security-Group"
    Environment = "dev"
    Owner       = "Princewill"
  }
}
