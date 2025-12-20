

# ---------------------------------------------------------------------------------------------------------------
# Security Group for public instances(using IGW) / app servers(using NAT GW) 
# ---------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "App servers SG"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] ##// [var.my_ip] 
  }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  description     = "Allow ICMP from web tier (for ping)"
  from_port       = -1
  to_port         = -1
  protocol        = "icmp"
  cidr_blocks      = [var.my_ip]
}

  tags = {
    Name = "app-sg"
  }
}

# ---------------------------------------------------------------------
# Data tier SG (NO internet dependency) (DATA TIER ONLY)
# ---------------------------------------------------------------------
resource "aws_security_group" "data_sg" {
  name   = "data-sg"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# ---------------------------------------------------------------------
# Security Group for VPC Endpoint Security Group (DATA TIER ONLY)
# ---------------------------------------------------------------------

resource "aws_security_group" "ssm_vpce" {
  name   = "ssm-vpce-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [
      aws_security_group.app_sg.id,
      aws_security_group.data_sg.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This SG allows instances in the EC2 SG to communicate with the VPC Endpoint over port 443
# ✔️ Allows Data EC2 → VPCE
