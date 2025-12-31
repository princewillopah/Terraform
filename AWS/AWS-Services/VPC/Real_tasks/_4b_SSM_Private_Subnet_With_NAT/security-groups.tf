resource "aws_security_group" "ssm_sg" {
  name   = "ssm-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssm-sg"
  }
}
