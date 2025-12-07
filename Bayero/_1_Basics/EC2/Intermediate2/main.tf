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

user_data = file("install2.sh") #handles instalation of docker on ec2 instance and running nginx on it
#  user_data = file("docker.sh")
# user_data = templatefile("./tools-install.sh", {})

 tags = {
    Name = "${var.environment}-Basic-ec2"
  }
}