# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "6.10.0"
#     }
#   }
# }


# --------------------------------------------------------------

#

# resource "aws_instance" "example" {
#   ami           = "ami-0360c520857e3138f" # Example Amazon Linux 2 AMI for us-east-1
#   instance_type = "t2.micro"              # Free tier eligible

#   tags = {
#     Name = "basic-ec2"
#   }
# }
# -----------------------------------------------------------------------
## without variables and outputs
# -----------------------------------------------------------------------
#  provider "aws" {
#    region = "us-east-1" # Change to your preferred region
#  }


# resource "aws_security_group" "ec2-security-group" {

#   ingress {
#     description      = "Open port 22 for cli access to the EC2 instance"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]  #for all ips to be able to access the ec2
#   }


# # the egress block handles rules for our resource within the vpc making requests or sending trafic outside the vpc to the internet. examples of such traffic is like when you want to install docker or other package in your EC2 instance, the binaries needs to be fectched or downloaded from the internet. another example, when we run an nginx image, the images has to be fetched from the dockerhub. these are requests made by the ec2 from your vpc to the internet  
#   egress {
#     description      = "rules to allow access of the resources inside the vpc to the internet"
#     from_port        = 0 # not restricting the request to any port out there is to set the value to 0
#     to_port          = 0 #same here
#     protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
#     cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
#   }

#   tags = {
#     Name = "test--security-group"
#   }
# }




# resource "aws_instance" "EKS-Bootstrap-Server" {
#   ami           = "ami-0360c520857e3138f" # 
#   instance_type = "t2.micro"

#   key_name = "prince-bayero-ssh"
#   vpc_security_group_ids = [aws_security_group.ec2-security-group.id]# this references the  security group above

# associate_public_ip_address    = true # to make sure public ip is display

#  root_block_device {
#     volume_size = 20
#     volume_type = "gp3"
#   }

#  tags = {
#     Name = "basic-ec2"
#   }
# }

# # --------------------------------------------------------------------
# include variables and outputs
# ------------------------------------------------------------------------

 provider "aws" {
   region = var.avail_zone # Change to your preferred region
 }


variable "avail_zone" {
 description = "Availability Zones"
 default     = "us-east-1"
}

variable "ami-xxx" {
  description = "AMI ID"
  default     = "ami-0360c520857e3138f"
}
variable "environment" {
  description = "EKS-Bootstrap-Server"
 default     = "Dev"
}




resource "aws_security_group" "ec2-security-group" {

  ingress {
    description      = "Open port 22 for cli access to the EC2 instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  #for all ips to be able to access the ec2
  }


# the egress block handles rules for our resource within the vpc making requests or sending trafic outside the vpc to the internet. examples of such traffic is like when you want to install docker or other package in your EC2 instance, the binaries needs to be fectched or downloaded from the internet. another example, when we run an nginx image, the images has to be fetched from the dockerhub. these are requests made by the ec2 from your vpc to the internet  
  egress {
    description      = "rules to allow access of the resources inside the vpc to the internet"
    from_port        = 0 # not restricting the request to any port out there is to set the value to 0
    to_port          = 0 #same here
    protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
    cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
  }

  tags = {
    Name = "${var.environment}-security-group"
  }
}




resource "aws_instance" "EKS-Bootstrap-Server" {
  ami           =  var.ami-xxx
  instance_type = "t2.micro"

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

resource "aws_instance" "EKS-Bootstrap-Server-2" {
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

output "instance_public_ip" {
  value = aws_instance.EKS-Bootstrap-Server.public_ip
}
output "instance_public_ip2" {
  value = aws_instance.EKS-Bootstrap-Server-2.public_ip
}

output "connection_to_linux_server" {
  value = "ssh -i ~/DevOps/prince-bayero-ssh.pem ubuntu@${aws_instance.EKS-Bootstrap-Server-2.public_ip}"
  # value = " ssh -i ${pathexpand(var.home_directory)}/${var.key_name} ubuntu@${aws_instance.Monitoring_Prometheus_target_Server.public_ip}"
}


