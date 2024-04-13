
resource "aws_key_pair" "myEKS-key-pair" {
  key_name   = "myEKS-sshkey-pair"
  public_key = file(var.public_key_location)
  
  tags = {
    Name = "${var.EC2_env_prefix}-key_pair"
  }
}


resource "aws_instance" "myEKS-worker-node-EC2-instance" {
  ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type = "t3.micro"

  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 

  subnet_id     =  var.subnet-id-for-EC2
  vpc_security_group_ids    = [aws_security_group.myEKS-security-group.id]
  availability_zone    = var.EC2_avail_zone[0]

  associate_public_ip_address    = true # to make sure public ip is display
  key_name     = aws_key_pair.myEKS-key-pair.key_name #stating that we are using an a keypair generated above


# user_data = file("docker-container.sh") #handles instalation of docker on ec2 instance and running nginx on it


 tags = {
    Name = "${var.EC2_env_prefix}-myEKS-EC2-instance"
  }
}