/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////


// To Generate Private Key
# resource "tls_private_key" "rsa_4096" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# # define a key name
# variable "key_name" {
#   description = "Name of the SSH key pair"
#   default = "Temp-EKS-bootstrap-server-sshkey"
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
  
  # description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myapp-vpc.id    #so the servers in the vpc can be associated weith the secuerity group

		#so ingress block handles the incoming requests/traffics to access the resources in the VPC such as accessing the ec2 instance from your CLI 0r accessing the nginx on port 8080 on port 22. in these cases we are sending traffic/requests to the VPC to access the EC2 instance or the nginx in it
  #rules to expose port 22 for aceessing ec2 instance ourside
  ingress {
    description      = "Open port 22 for cli access to the EC2 instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    # cidr_blocks      = [var.my-ip] only that stated ip will be able to access the ip
    cidr_blocks      = ["0.0.0.0/0"]  #for all ips to be able to access the ec2
  }
#rules to expose port 22 for aceessing ec2 instance ourside
  ingress {
    description      = "Open port 80 for access of the nginx server in the ec2 instance from a browser "
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
  }
#rules to expose port 22 for aceessing ec2 instance ourside
  ingress {
    description      = "Open port 8080 for access of the nginx server in the ec2 instance from a browser "
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
  }
#rules to expose port 22 for aceessing ec2 instance ourside
  ingress {
    description      = "Open port 8081 for access of the nexus server in the ec2 instance from a browser "
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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


resource "aws_instance" "EKS-Bootstrap-Server" {
  ami           = "ami-0914547665e6a707c" # for eu-north-1
  instance_type = "t3.micro"

  #  ami          =  ami-059a8f02a1a1fd2b9 # for eu-north-1
  #  instance_type = "t4g.small"

  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
  subnet_id     =  aws_subnet.my_public_subnet.id
  vpc_security_group_ids    = [aws_security_group.ec2-security-group.id]
  availability_zone    = var.avail_zone
  key_name               = "Prince-Affy-Main-SSHKEY"



associate_public_ip_address    = true # to make sure public ip is display
# key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above
user_data = file("install.sh") #handles instalation of docker on ec2 instance and running nginx on it
 root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

 tags = {
    Name = "${var.environment}"
  }
}





