resource "aws_instance" "private_ec2" {
  ami                    = "ami-0532be01f26a3de55" # Amazon Linux 2 (us-east-1)
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.ssm_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "private-ssm-instance"
  }
}

