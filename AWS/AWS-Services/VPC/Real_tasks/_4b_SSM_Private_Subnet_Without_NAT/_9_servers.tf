# data "aws_ami" "al2023" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-x86_64"]
#   }
# }

# resource "aws_instance" "data_tier" {
#   ami           = data.aws_ami.al2023.id
#   instance_type = "t3.micro"
#   subnet_id     = aws_subnet.private_data_1a.id

#   vpc_security_group_ids = [aws_security_group.data_sg.id]
#   iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
# }


resource "aws_instance" "data_tier" {

  ami           = "ami-063b41f7b226524e4"  # note that this AMI needs to have SSM agent pre-installed
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