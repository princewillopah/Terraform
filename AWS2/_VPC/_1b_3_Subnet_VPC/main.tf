#######---------------------------------------
####### VPC
#######---------------------------------------

provider "aws" {
  region = "eu-north-1"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "my_public_subnet" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.myapp-vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.avail_zone, count.index)
  # cidr_block              = cidrsubnet(aws_vpc.myapp-vpc.cidr_block, 3, count.index)
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.myapp-vpc.id
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}


resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs) 
  subnet_id      = aws_subnet.my_public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}
# resource "aws_route_table_association" "public_subnet_asso" {
#  count = length(var.public_subnet_cidrs)
#  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
#  route_table_id = aws_route_table.public_route_table.id
# }
#######---------------------------------------
####### SSH Key Generation
#######---------------------------------------

// To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# define a key name
variable "key_name" {
  description = "Name of the SSH key pair"
  default = "Temp-EKS-bootstrap-server-sshkey"
}

// Define the home directory variable
variable "home_directory" {
  description = "The user's home directory"
  default = "C:/Users/PB/.ssh"
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

#######---------------------------------------
####### SG Key Generation
#######---------------------------------------


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
    Name = "${var.environment}-security-group"
  }
}


#######---------------------------------------
####### EC2 instances
#######---------------------------------------

resource "aws_instance" "EKS-Bootstrap-Server" {
  count                     = length(var.public_subnet_cidrs)
  ami           = "ami-0914547665e6a707c" # for eu-north-1
  instance_type = "t3.micro"

  #  ami          =  ami-059a8f02a1a1fd2b9 # for eu-north-1
  #  instance_type = "t4g.small"

  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
   
  
  subnet_id                 = element(aws_subnet.my_public_subnet[*].id, count.index)
  vpc_security_group_ids    = [aws_security_group.ec2-security-group.id]
  availability_zone         = element(var.avail_zone, count.index)
  key_name                  = aws_key_pair.key_pair.key_name
   


associate_public_ip_address    = true # to make sure public ip is display
# key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above
user_data = file("install.sh") #handles instalation of docker on ec2 instance and running nginx on it
 root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

tags = {
  Name = "Server-${count.index + 1}" # Tagging each EC2 instance with Server-1, Server-2, and Server-3
}



}

## ===========================================================================================================================
## # Explanation
## ===========================================================================================================================

# This Terraform code defines an AWS subnet resource with specific attributes. 
# Each line configures different properties of the subnet. Let's break down the code in detail:

# resource "aws_subnet" "public" {
#   count                   = 3
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index)
#   availability_zone       = element(["eu-north-1a", "eu-north-1b", "eu-north-1c"], count.index)
# }




# Explanation
# resource "aws_subnet" "public":

# This declares a resource block in Terraform to create AWS subnets.
# "aws_subnet" specifies the type of resource.
# "public" is the name of this resource, allowing it to be referenced elsewhere in your Terraform configuration.
# count = 3:

# This sets the number of subnet resources to create to 3.
# Terraform will create three subnets, indexed from 0 to 2.
# vpc_id = aws_vpc.main.id:

# This assigns the ID of the VPC (Virtual Private Cloud) to which the subnets will belong.
# aws_vpc.main.id references the id attribute of a VPC resource named main.
# cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 3, count.index):

# This uses the cidrsubnet function to calculate the CIDR block for each subnet.
# aws_vpc.main.cidr_block: The base CIDR block of the VPC.
# 3: The number of additional bits to add to the subnet mask, which creates subnets within the VPC.
# count.index: The current index in the count loop (0, 1, or 2), used to calculate unique subnets.
# availability_zone = element(["eu-north-1a", "eu-north-1b", "eu-north-1c"], count.index):

# This assigns an availability zone to each subnet.
# element(["eu-north-1a", "eu-north-1b", "eu-north-1c"], count.index): The element function selects an element from the list based on the count.index. This ensures each subnet is placed in a different availability zone.
# Detailed Breakdown of Functions
# cidrsubnet(cidr, newbits, netnum):

# cidr: The base CIDR block (e.g., 10.0.0.0/16).
# newbits: The number of bits added to the subnet mask (e.g., 3), which defines the size of each subnet.
# netnum: The subnet number within the new address space (e.g., count.index).
# This function calculates a subnet CIDR block within the specified address space.
# element(list, index):

# list: A list of elements (e.g., ["eu-north-1a", "eu-north-1b", "eu-north-1c"]).
# index: The index to select an element (e.g., count.index).
# This function returns the element at the specified index, allowing for selection from the list.
# Example Scenario
# Assume the VPC CIDR block is 10.0.0.0/16:

# For count.index = 0:

# cidrsubnet(10.0.0.0/16, 3, 0) might produce 10.0.0.0/19.
# element(["eu-north-1a", "eu-north-1b", "eu-north-1c"], 0) returns eu-north-1a.
# For count.index = 1:

# cidrsubnet(10.0.0.0/16, 3, 1) might produce 10.0.32.0/19.
# element(["eu-north-1a", "eu-north-1b", "eu-north-1c"], 1) returns eu-north-1b.
# For count.index = 2:

# cidrsubnet(10.0.0.0/16, 3, 2) might produce 10.0.64.0/19.
# element(["eu-north-1a", "eu-north-1b", "eu-north-1c"], 2) returns eu-north-1c.
# This setup ensures that three subnets are created within the VPC, each in a different availability zone and with unique CIDR blocks.