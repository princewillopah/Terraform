resource "aws_instance" "public_ec2" {
  ami                    = "ami-0ecb62995f68bb549" # Amazon Linux 2 (us-east-1)  // ami-0ecb62995f68bb549
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssm_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "public-ssm-instance"
  }
}
