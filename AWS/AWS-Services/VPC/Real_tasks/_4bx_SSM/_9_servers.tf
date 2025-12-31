resource "aws_instance" "web_tier" {

  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_1a.id

  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
 user_data = file("${path.module}/tools-install.sh")

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.app_name}-Web-Tier"
  }
}




resource "aws_instance" "app_tier" {

  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_app_1a.id


  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
 user_data = file("${path.module}/tools-install.sh")

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.app_name}-App-Tier"
  }
}







resource "aws_instance" "data_tier" {

  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_data_1a.id

 user_data = file("${path.module}/tools-install.sh")
  vpc_security_group_ids = [aws_security_group.data_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.app_name}-Data-Tier"
  }
}