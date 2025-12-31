

# ------------------------------------------------------------------
# App servers SG
# ------------------------------------------------------------------

resource "aws_security_group" "app-server-security-group" {
  name   = "App-server-security-group"
  vpc_id      =  aws_vpc.vpc.id 

  #   ingress {
  #   description      = "Open port 22 for cli access to the EC2 instance"
  #   from_port        = 22
  #   to_port          = 22
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]  #allow access from the web security group to the app security group
  # }

  #   ingress {
  #   description     = "Allow ICMP from web tier (for ping)"
  #   from_port       = -1
  #   to_port         = -1
  #   protocol        = "icmp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   }

    ingress {
      description     = "for http access to web server"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    description      = "rules to allow access of the resources inside the vpc to the internet"
    from_port        = 0 # not restricting the request to any port out there is to set the value to 0
    to_port          = 0 #same here
    protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
    cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
  }

  tags = {
    Name = "${var.app_name}-Jump-server-SG"
  }
}



# ------------------------------------------------------------------
# DATabases servers SG
# ------------------------------------------------------------------

resource "aws_security_group" "db-server-security-group" {
  name   = "DB-server-security-group"

  vpc_id      =  aws_vpc.vpc.id 

  #   ingress {
  #   description      = "Open port 22 for cli access to the EC2 instance"
  #   from_port        = 22
  #   to_port          = 22
  #   protocol         = "tcp"
  #   security_groups      = [aws_security_group.app-server-security-group.id]  #allow access from the web security group to the app security group
  # }

  #   ingress {
  #   description     = "Allow ICMP from web tier (for ping)"
  #   from_port       = -1
  #   to_port         = -1
  #   protocol        = "icmp"
  #   security_groups = [aws_security_group.app-server-security-group.id]
  #   }

 ingress {
      description     = "for http access to web server"
      from_port       = 27017
      to_port         = 27017
      protocol        = "tcp"
      security_groups = [aws_security_group.app-server-security-group.id] # allow access from app server sg to db server sg
    }

 egress {
    description      = "rules to allow access of the resources inside the vpc to the internet"
    from_port        = 0 # not restricting the request to any port out there is to set the value to 0
    to_port          = 0 #same here
    protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
    cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
  }

  tags = {
    Name = "${var.app_name}-DB-server-SG"
  }
}


# ------------------------------------------------------------------
# vpc endpoint SG
# ------------------------------------------------------------------

resource "aws_security_group" "vpc-endpoint-security-group" {
  name   = "vpc-endpoint-security-group"

  vpc_id      =  aws_vpc.vpc.id 

 ingress {
      description     = "for http access to web server"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
       security_groups = [ aws_security_group.app-server-security-group.id,
                           aws_security_group.db-server-security-group.id ]
    }
  egress {
    description      = "rules to allow access of the resources inside the vpc to the internet"
    from_port        = 0 # not restricting the request to any port out there is to set the value to 0
    to_port          = 0 #same here
    protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
    cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
  }
  tags = {
    Name = "${var.app_name}-vpc-endpoint-SG"
  }
}
