
## --------------------------------------------------------------------------------------------------------------------------------------------------
## Security Group (Database Firewall)
## --------------------------------------------------------------------------------------------------------------------------------------------------


resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg-"
  description = "Security group for RDS MySQL instance"
  vpc_id      = aws_vpc.rds_vpc.id

  # Allow inbound MySQL (port 3306) from your app or your IP
  ingress {
    description = "MySQL access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    # 🔒 For production, restrict to application servers or specific IPs
    # cidr_blocks = ["0.0.0.0/0"] # ❗ Replace with your app's SG or IP (e.g., ["203.0.113.2/32"] or range of IP's e.g., ["203.0.113.0/24"] )
    security_groups = [aws_security_group.jumpbox-security-group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }

}
