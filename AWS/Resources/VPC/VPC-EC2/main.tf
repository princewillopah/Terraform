//-----------------------------------------------------
// VPC
//----------------------------------------------------


resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.environment}-VPC"
  }
}

//-----------------------------------------------------
// Subnets 
//----------------------------------------------------

# Create public subnets within the AWS VPC using the "aws_subnet" resource.
resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnet_cidrs)  # Create one subnet per value in public_subnet_cidrs
  vpc_id     = aws_vpc.my-vpc.id                   # Associate these subnets with an existing VPC
  cidr_block = element(var.public_subnet_cidrs, count.index)  # Use the CIDR block from the variable list
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "Public Subnet ${count.index + 1}"  # Name each subnet uniquely based on its index
  }
}

# Create private subnets within the AWS VPC using the "aws_subnet" resource.
resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnet_cidrs)  # Create one subnet per value in private_subnet_cidrs
  vpc_id     = aws_vpc.my-vpc.id                   # Associate these subnets with an existing VPC
  cidr_block = element(var.private_subnet_cidrs, count.index)  # Use the CIDR block from the variable list
  availability_zone = element(var.azs, count.index) # specify the zone for this subnet
  tags = {
    Name = "Private Subnet ${count.index + 1}"  # Name each subnet uniquely based on its index
  }
}


//-----------------------------------------------------
// public route table
//----------------------------------------------------
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.my-vpc.id
 
 tags = {
   Name = "${var.environment}-VPC-IGW"
 }
}

resource "aws_route_table" "Public_Route_Table" {
 vpc_id = aws_vpc.my-vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "Public Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.Public_Route_Table.id
}


//-----------------------------------------------------
// private route table
//----------------------------------------------------

# Create a private route table
resource "aws_route_table" "Private_Route_Table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = aws_vpc.my-vpc.cidr_block  # # Local route within the VPC //  cidr_block =  "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "Private Route Table"
  }
}



# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.Private_Route_Table.id
}



//-----------------------------------------------------
// NSG
//----------------------------------------------------
resource "aws_security_group" "my-nsg" {
  name        = "Network-Security Group"
  description = "Open 22,443,80,8080,9000"
  vpc_id      = aws_vpc.my-vpc.id    #so the servers in the vpc can be associated weith the secuerity group
  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000,3306] : {
      description      = "TLS from VPC"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-NSG"
  }
}





# resource "aws_default_security_group" "myapp-default-security-group" {
  
#   # description = "Allow TLS inbound traffic"
#   vpc_id      = aws_vpc.my-vpc.id    #so the servers in the vpc can be associated weith the secuerity group

# 		#so ingress block handles the incoming requests/traffics to access the resources in the VPC such as accessing the ec2 instance from your CLI 0r accessing the nginx on port 8080 on port 22. in these cases we are sending traffic/requests to the VPC to access the EC2 instance or the nginx in it
#   #rules to expose port 22 for aceessing ec2 instance ourside
#   ingress {
#     description      = "Open port 22 for cli access to the EC2 instance"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     # cidr_blocks      = [var.my-ip] only that stated ip will be able to access the ip
#     cidr_blocks      = ["0.0.0.0/0"]  #for all ips to be able to access the ec2
#   }
# #rules to expose port 22 for aceessing ec2 instance ourside
#   ingress {
#     description      = "Open port 8080 for access of the nginx server in the ec2 instance from a browser "
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
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
#     Name = "${var.env_prefix}-default-security-group"
#   }
# }


//-----------------------------------------------------
// SSHKEY
//----------------------------------------------------

// To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# define a key name
variable "key_name" {
  description = "Name of the SSH key pair"
  default = "temporal-sshkey"
}

// Define the home directory variable
variable "home_directory" {
  description = "The user's home directory"
  default = "~/.ssh"
}

// Create Key Pair for Connecting EC2 via SSH
resource "aws_key_pair" "my-key-pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
   tags = {
    Name = "${var.environment}-key_pair"
  }
}

// Save PEM file locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem

 filename = "${pathexpand(var.home_directory)}/${var.key_name}"
  provisioner "local-exec" { 
   command = "chmod 400 ${pathexpand(var.home_directory)}/${var.key_name}"
  }
}

//-----------------------------------------------------
// multiple ec2
//----------------------------------------------------

resource "aws_instance" "myapp-EC2-instance" {
  count = 2   // Use count to create only one instance
  ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type = "t3.micro"

  # subnet_id     =  aws_subnet.public_subnets[].id
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)  //
  # vpc_security_group_ids = count.index == 0 ? [aws_security_group.my-nsg.id] : [] ///
  vpc_security_group_ids    = [aws_security_group.my-nsg.id]

  availability_zone = element(var.azs, count.index)

  associate_public_ip_address    = true
  key_name     = aws_key_pair.my-key-pair.key_name 


 tags = {
    Name = "${var.environment}-EC2-instance"
  }
}

//-----------------------------------------------------
// EC2
//----------------------------------------------------
# resource "aws_instance" "myapp-EC2-instance" {
#   ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
#   instance_type = "t3.micro"

#   # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
# subnet_id     =  aws_subnet.public_subnets[].id
# vpc_security_group_ids    = [aws_default_security_group.my-nsg.id]
# availability_zone    = var.avail_zone

# associate_public_ip_address    = true # to make sure public ip is display
# key_name     = aws_key_pair.my-key-pair.key_name #stating that we are using an a keypair generated above


# # user_data = file("docker-container.sh") #handles instalation of docker on ec2 instance and running nginx on it

#  tags = {
#     Name = "${var.environment}-EC2-instance"
#   }
# }


//-----------------------------------------------------
// VPC
//----------------------------------------------------

//-----------------------------------------------------
// VPC
//----------------------------------------------------

//-----------------------------------------------------
// VPC
//----------------------------------------------------

//-----------------------------------------------------
// VPC
//----------------------------------------------------
