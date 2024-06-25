/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////


// To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# define a key name
variable "key_name" {
  description = "Name of the SSH key pair"
  default = "disposible-sshkey"
}

// Define the home directory variable
variable "home_directory" {
  description = "The user's home directory"
  default = "~/.ssh"
}

// Create Key Pair for Connecting EC2 via SSH
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
   tags = {
    Name = "${var.environment}-key_pair"
  }
}

// Save PEM file locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  # filename = var.key_name #save in root dir of this project
  # filename = "${pathexpand("~/.ssh/")}${var.key_name}" #${pathexpand("~/.ssh/")} is used to get the path to the user's home directory, and then ${var.key_name} is appended to specify the full path to the key file in the .ssh directory. 

 filename = "${pathexpand(var.home_directory)}/${var.key_name}"
  provisioner "local-exec" { # The local-exec provisioner is also updated to use the same path when running the chmod command.
    # command = "chmod 400 ${var.key_name}" 
   command = "chmod 400 ${pathexpand(var.home_directory)}/${var.key_name}"
  }
}

/////////////////////////////////////////////////////////////////////
///  EC2 INSTANCES  
/////////////////////////////////////////////////////////////////////

// EC2 Instances
resource "aws_instance" "EC2_Instance_1" {
  ami                     = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type           = "t3.micro"
  key_name                = aws_key_pair.key_pair.key_name
  vpc_security_group_ids  = [aws_security_group.tomcat_app_security_group.id]
  associate_public_ip_address = true
  root_block_device {
    volume_size = 9
    volume_type = "gp2"
  }
  tags = {
    Name = "${var.environment1}"
  }
}

resource "aws_instance" "EC2_Instance_2" {
  ami                     = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type           = "t3.micro"
  key_name                = aws_key_pair.key_pair.key_name
  vpc_security_group_ids  = [aws_security_group.backend_services_security_group.id]
  associate_public_ip_address = true
  root_block_device {
    volume_size = 9
    volume_type = "gp2"
  }
  tags = {
    Name = "${var.environment2}"
  }
}

resource "aws_instance" "EC2_Instance_3" {
  ami                     = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type           = "t3.micro"
  key_name                = aws_key_pair.key_pair.key_name
  vpc_security_group_ids  = [aws_security_group.backend_services_security_group.id]
  associate_public_ip_address = true
  root_block_device {
    volume_size = 9
    volume_type = "gp2"
  }
  tags = {
    Name = "${var.environment3}"
  }
}

resource "aws_instance" "EC2_Instance_4" {
  ami                     = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type           = "t3.micro"
  key_name                = aws_key_pair.key_pair.key_name
  vpc_security_group_ids  = [aws_security_group.backend_services_security_group.id]
  associate_public_ip_address = true
  root_block_device {
    volume_size = 9
    volume_type = "gp2"
  }
  tags = {
    Name = "${var.environment4}"
  }
}

///////////////////////////////////////////////
# old
///////////////////////////////////////////////

# resource "aws_instance" "EC2-Instance-1" {
#   ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
#   instance_type = "t3.micro"

#   # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
#   key_name               = aws_key_pair.key_pair.key_name
#   vpc_security_group_ids = [aws_security_group.tomcat-app-security-group.id]


# associate_public_ip_address    = true # to make sure public ip is display
# # user_data = file("install-Java-and-Jenkins.sh") #handles instalation of docker on ec2 instance and running nginx on it

#  root_block_device {
#     volume_size = 9
#     volume_type = "gp2"
#   }

#  tags = {
#     Name = "${var.environment1}"
#   }
# }


# // 2ND EC2
# resource "aws_instance" "EC2-Instance-2" {
#   ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
#   instance_type = "t3.micro"

#   # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
#   key_name               = aws_key_pair.key_pair.key_name
#   vpc_security_group_ids = [aws_security_group.backend-services-security-group.id]


# associate_public_ip_address    = true # to make sure public ip is display
# # user_data = file("install-git-and-mariadb.sh") #handles instalation of docker on ec2 instance and running nginx on it
 
 
#  root_block_device {
#     volume_size = 9
#     volume_type = "gp2"
#   }

#  tags = {
#     Name = "${var.environment2}"
#   }
# }


# // 3RD EC2
# resource "aws_instance" "EC2-Instance-3" {
#   ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
#   instance_type = "t3.micro"

#   # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
#   key_name               = aws_key_pair.key_pair.key_name
#   vpc_security_group_ids = [aws_security_group.backend-services-security-group.id]


# associate_public_ip_address    = true # to make sure public ip is display
# # key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above
# # user_data = file("install-memcache.sh") #handles instalation of docker on ec2 instance and running nginx on it
 
#  root_block_device {
#     volume_size = 9
#     volume_type = "gp2"
#   }

#  tags = {
#     Name = "${var.environment3}"
#   }
# }


# // 4th EC2
# resource "aws_instance" "EC2-Instance-4" {
#   ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
#   instance_type = "t3.micro"

#   # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
#   key_name               = aws_key_pair.key_pair.key_name
#   vpc_security_group_ids = [aws_security_group.backend-services-security-group.id]


# associate_public_ip_address    = true # to make sure public ip is display
# # key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above
# # user_data = file("install-Java-and-Jenkins.sh") #handles instalation of docker on ec2 instance and running nginx on it
 
#  root_block_device {
#     volume_size = 9
#     volume_type = "gp2"
#   }

#  tags = {
#     Name = "${var.environment4}"
#   }
# }

# // 5th EC2
# resource "aws_instance" "EC2-Instance-5" {
#   ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
#   instance_type = "t3.micro"
#   # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
#   key_name               = aws_key_pair.key_pair.key_name
#   vpc_security_group_ids = [aws_security_group.ec2-security-group.id]
# associate_public_ip_address    = true # to make sure public ip is display
# # key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above
# # user_data = file("install-Java-and-Jenkins.sh") #handles instalation of docker on ec2 instance and running nginx on it
#  root_block_device {
#     volume_size = 9
#     volume_type = "gp2"
#   }
#  tags = {
#     Name = "${var.environment5}"
#   }
# }


