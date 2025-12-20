resource "aws_instance" "app-Server1" {
  ami           = "ami-0ecb62995f68bb549" # for us-east-1
  instance_type = "t3.micro"


  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
  subnet_id     =  var.subnets[2]
  vpc_security_group_ids    = [aws_security_group.app-tier-security-group.id]
  key_name               = "Princewill-ssh-bayero-sub" # to be used by web server to access app server via ssh
#  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  user_data = templatefile("./user-data.sh", {})
  
 root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

 tags = {
    Name = "app-EC2"
  }
}




resource "aws_instance" "app-Server2" {
  ami           = "ami-0ecb62995f68bb549" # for us-east-1
  instance_type = "t3.micro"


  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
  subnet_id     =  var.subnets[3]
  vpc_security_group_ids    = [aws_security_group.app-tier-security-group.id]
  key_name               = "Princewill-ssh-bayero-sub" # to be used by web server to access app server via ssh
#  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  user_data = templatefile("./user-data.sh", {})
  
 root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

 tags = {
    Name = "app-EC2"
  }
}
