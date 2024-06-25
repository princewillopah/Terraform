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
  default = "temporal-jenkins-master-sshkey"
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


/////////////////////////////////////////////////////////////////////





resource "aws_security_group" "ec2-security-group" {

  ingress {
    description      = "Open port 22 for cli access to the EC2 instance"
    from_port        = 22
    to_port          = 500
    protocol         = "tcp"
    # cidr_blocks      = [var.my-ip] only that stated ip will be able to access the ip
    cidr_blocks      = ["0.0.0.0/0"]  #for all ips to be able to access the ec2
  }

  ingress {
    description      = "Open port 8080 for access of the nginx server in the ec2 instance from a browser "
    from_port        = 8000
    to_port          = 10000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
  }

  ingress {
    from_port   = 3000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


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


resource "aws_instance" "Jenkins-Master-Instance" {
  ami           = "ami-0014ce3e52359afbd" # for eu-north-1
  instance_type = "t3.large"


  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]


associate_public_ip_address    = true # to make sure public ip is display

user_data = file("install-Java-and-Jenkins.sh") #handles instalation of docker on ec2 instance and running nginx on it



 root_block_device {
    volume_size = 40
    volume_type = "gp2"
  }

 tags = {
    Name = "${var.environment}"
  }
}





