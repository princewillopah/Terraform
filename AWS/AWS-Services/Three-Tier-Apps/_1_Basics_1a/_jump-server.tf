
resource "aws_instance" "Jump_Server" {
  ami           = var.ami # for us-east-1
  instance_type = var.instance_type

  subnet_id     =  aws_subnet.jumpbox_subnet.id
  vpc_security_group_ids    = [aws_security_group.Jump-server-security-group.id]
  key_name               = var.key_name



associate_public_ip_address    = true 

 root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

 tags = {
    Name = "${var.app_name}-Jump-Server"
  }
}
