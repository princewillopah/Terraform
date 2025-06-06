/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////


# // To Generate Private Key
# resource "tls_private_key" "rsa_4096" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # define a key name
# variable "key_name" {
#   description = "Name of the SSH key pair"
#   default = "temporal-T3-Medium-Server-sshkey"
# }

# // Define the home directory variable
# variable "home_directory" {
#   description = "The user's home directory"
#   default = "~/.ssh"
# }

# // Create Key Pair for Connecting EC2 via SSH
# resource "aws_key_pair" "key_pair" {
#   key_name   = var.key_name
#   public_key = tls_private_key.rsa_4096.public_key_openssh
#    tags = {
#     Name = "${var.environment}-key_pair"
#   }
# }

# // Save PEM file locally
# resource "local_file" "private_key" {
#   content  = tls_private_key.rsa_4096.private_key_pem
#   # filename = var.key_name #save in root dir of this project
#   # filename = "${pathexpand("~/.ssh/")}${var.key_name}" #${pathexpand("~/.ssh/")} is used to get the path to the user's home directory, and then ${var.key_name} is appended to specify the full path to the key file in the .ssh directory. 

#  filename = "${pathexpand(var.home_directory)}/${var.key_name}"
#   provisioner "local-exec" { # The local-exec provisioner is also updated to use the same path when running the chmod command.
#     # command = "chmod 400 ${var.key_name}" 
#    command = "chmod 400 ${pathexpand(var.home_directory)}/${var.key_name}"
#   }
# }

/////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////


resource "aws_security_group" "ec2-security-group" {
#  vpc_id = var.vpc_id
 ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust as necessary for security
  }

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust as necessary for security
  }

  ingress {
    description      = "Open port 22,25,80,443,465 for ssh, SMTP, HTTP,HTTPS, STMPS "
    from_port        = 20
    to_port          = 600
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  #for all ips to be able to access the ec2
  }
  ingress {
    description      = "Open port for 8081 for access of the nginx server in the ec2 instance from a browser "
    from_port        = 2000
    to_port          = 11000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
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
    Name = "${var.environment}--security-group"
  }
}


resource "aws_instance" "T3-Medium-Server" {
  ami           = "ami-08eb150f611ca277f" # for eu-north-1
  instance_type = "t3.small"


  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
  # key_name               = aws_key_pair.key_pair.key_name
  key_name               = var.ssh-key
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]
  # subnet_id             = var.public_subnet_id  # Specify the public subnet ID here

  associate_public_ip_address    = true # to make sure public ip is display
  # key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above
  iam_instance_profile   = aws_iam_instance_profile.instance-profile.name


  root_block_device {
      volume_size = 30
      volume_type = "gp2"
    }
  user_data = file("docker-setup.sh") #handles instalation of docker on ec2 instance and running nginx on it
  tags = {
      Name = "${var.environment}"
    }
}





