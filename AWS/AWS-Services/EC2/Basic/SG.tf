resource "aws_security_group" "Jump-server-security-group" {
  name   = "Jump-server-security-group"

  # vpc_id      = var.   


  ingress {
    description      = "Open port 22 for cli access to the EC2 instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip] # only that stated ip will be able to access the ip
    # cidr_blocks      = ["0.0.0.0/0"]  #for all ips to be able to access the ec2
  }

  egress {
    description      = "rules to allow access of the resources inside the vpc to the internet"
    from_port        = 0 # not restricting the request to any port out there is to set the value to 0
    to_port          = 0 #same here
    protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
    cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
  }

  tags = {
    Name = "Jump-server-SG"
  }
}
# -----------------------------------------------------------------

resource "aws_security_group" "app-tier-security-group" {
name   = "app-tier-security-group"

  vpc_id      = "vpc-08fa31b417bae82b6"   


  ingress {
    description      = "Open port 22 for cli access to the EC2 instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups      = [aws_security_group.web-tier-security-group.id]  #allow access from the web security group to the app security group
  }

ingress {
  description     = "Allow ICMP from web tier (for ping)"
  from_port       = -1
  to_port         = -1
  protocol        = "icmp"
  security_groups = [aws_security_group.web-tier-security-group.id]
}

  egress {
    description      = "rules to allow access of the resources inside the vpc to the internet"
    from_port        = 0 # not restricting the request to any port out there is to set the value to 0
    to_port          = 0 #same here
    protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
    cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
  }

  tags = {
    Name = "app-tier-security-group"
  }
}

# -----------------------------------------------------------------

resource "aws_security_group" "data-tier-security-group" {
   name   = "data-tier-security-group"
  vpc_id      = "vpc-08fa31b417bae82b6"   

  ingress {
    description      = "Open port 22 for cli access to the EC2 instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups      = [aws_security_group.app-tier-security-group.id]  #allow access from the web security group to the app security group
  }

ingress {
  description     = "Allow ICMP from web tier (for ping)"
  from_port       = -1
  to_port         = -1
  protocol        = "icmp"
  security_groups = [aws_security_group.app-tier-security-group.id]
}

  egress {
    description      = "rules to allow access of the resources inside the vpc to the internet"
    from_port        = 0 # not restricting the request to any port out there is to set the value to 0
    to_port          = 0 #same here
    protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
    cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
  }

  tags = {
    Name = "data-tier-security-group"
  }
}