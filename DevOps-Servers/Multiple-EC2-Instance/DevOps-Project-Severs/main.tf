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


/////////////////////////////////////////////////////////////////////





resource "aws_security_group" "ec2-security-group" {
   name        = "Jenkins-pipeline-SG"
  description = "Allow TLS inbound traffic"
  # description = "Allow TLS inbound traffic"
#   vpc_id      = aws_vpc.myapp-vpc.id    #so the servers in the vpc can be associated weith the secuerity group

		#so ingress block handles the incoming requests/traffics to access the resources in the VPC such as accessing the ec2 instance from your CLI 0r accessing the nginx on port 8080 on port 22. in these cases we are sending traffic/requests to the VPC to access the EC2 instance or the nginx in it
  #rules to expose port 22 for aceessing ec2 instance ourside
  ingress [
     for port in [22, 80, 443, 8080, 9000, 3000] : {
          description      = "inbound rules"
          from_port        = port
          to_port          = port
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          security_groups  = []
          self             = false
    }
  ]

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


resource "aws_instance" "Jenkin-Master-EC2-Instance" {
  ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type = "t3.micro"

  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]


associate_public_ip_address    = true # to make sure public ip is display
# key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above

 root_block_device {
    volume_size = 9
    volume_type = "gp2"
  }

 tags = {
    Name = "${var.environment1}"
  }
}

resource "aws_instance" "Jenkin-Slave1-EC2-Instance" {
  ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type = "t3.micro"

  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]


associate_public_ip_address    = true # to make sure public ip is display
# key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above

 root_block_device {
    volume_size = 9
    volume_type = "gp2"
  }

 tags = {
    Name = "${var.environment2}"
  }
}

resource "aws_instance" "Ansible-EC2-Instance" {
  ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type = "t3.micro"

  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
  key_name               = aws_key_pair.key_pair.key_name
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]


associate_public_ip_address    = true # to make sure public ip is display
# key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above

 root_block_device {
    volume_size = 9
    volume_type = "gp2"
  }

 tags = {
    Name = "${var.environment3}"
  }
}


