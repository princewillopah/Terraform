resource "aws_instance" "EKS-Bootstrap-Server" {
  ami           =  var.ami-xxx
  instance_type = "t3.micro"

  key_name = "prince-bayero-ssh"
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]# this references the  security group above

associate_public_ip_address    = true # to make sure public ip is display

 root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

 tags = {
    Name = "${var.environment}-Basic-ec2"
  }
}