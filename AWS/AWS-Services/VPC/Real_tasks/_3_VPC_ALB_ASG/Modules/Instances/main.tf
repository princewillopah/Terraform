
resource "aws_instance" "Jump-Server" {
  ami           = "ami-0ecb62995f68bb549" # for us-east-1
  instance_type = "t3.micro"


  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
  subnet_id     =  var.public_subnet_az1  // we are placing the jump server in the public subnet
  vpc_security_group_ids    = [aws_security_group.jump-host-security-group.id]
  key_name               = "Princewill-ssh-bayero-sub"
  iam_instance_profile  = var.iam_instance_profile


associate_public_ip_address    = true # to make sure public ip is display
# key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above
# user_data = file("install.sh") #handles instalation of docker on ec2 instance and running nginx on it
 root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

 tags = {
    Name = "web-EC2"
  }
}

