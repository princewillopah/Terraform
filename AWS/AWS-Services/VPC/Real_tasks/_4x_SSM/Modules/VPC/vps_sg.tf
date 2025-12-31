# ---------------------------------------------------------------------
# Security Group for VPC Endpoint Security Group (DATA TIER ONLY)
# ---------------------------------------------------------------------

resource "aws_security_group" "ssm_vpce" {
  name   = "ssm-vpce-sg"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
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


# ---------------------------------------------------------------------------------------------------------------
# Security Group for public instances(using IGW) / app servers(using NAT GW) / data servers using VPC endpoints
# ---------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "public_sg" {
  name        = "app-sg"
  description = "App servers SG"
  vpc_id      = aws_vpc.app_vpc.id

   egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

# This Works for IGW, NAT, and VPC-Endpoint based instances


# ----------------------------------------------------------------------------------------------