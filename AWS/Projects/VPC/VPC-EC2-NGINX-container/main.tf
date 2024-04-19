
# vpc
resource "aws_vpc" "myapp-vpc" {
  cidr_block       = var.vpc_cidr_block


  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# 
# subnet
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id     = aws_vpc.myapp-vpc.id  #the only requiered atteributes
  cidr_block = "10.0.1.0/24"
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

# this is to create an internet gateway. An Internet Gateway is a logical connection between an AWS VPC and the Internet. It allows for internet traffic to actually enter into a VPC
resource "aws_internet_gateway" "myapp-internet-gateway" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "${var.env_prefix}-internet-gateway"
  }
}

# # THIS DEFAULT ROUTE TABLE IS USED WHEN WE WANT TO USE THE DEFUAULT TABLE ASSOCIATED WITH THE VCP WE CREATED
# we are going to use the default route-table created instaed of creating a new one shoew below after this default block
resource "aws_default_route_table" "default-route-table" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

   route { #this is perovided by default. This means that omitting this argument is interpreted as ignoring any existing routes. To remove all managed routes an empty list should be specified
    # cidr_block = "10.1.0.0/16"  this line will be provided by default if not specified. it picks the vpc cidr ip
     cidr_block = "0.0.0.0/0" # this is fer te internet gateway
    gateway_id = aws_internet_gateway.myapp-internet-gateway.id
  }
  tags = {
    Name = "${var.env_prefix}-default-router-table"
  }
}

## note, if route table is not created using the terraform during generation of the vpc, aws will create a default route table for you, 
## specifying the using cidr ip  of the vpc. the route object will be "local" stating that the traffic can only be within the vpc
resource "aws_route_table" "myapp-router-table" {
 vpc_id = aws_vpc.myapp-vpc.id

  # since this is exactly the route AWS will create, the route will be adopted
  route { #this is perovided by default. This means that omitting this argument is interpreted as ignoring any existing routes. To remove all managed routes an empty list should be specified
    # cidr_block = "10.1.0.0/16"  this line will be provided by default if not specified. it picks the vpc cidr ip
     cidr_block = "0.0.0.0/0" # this is fer te internet gateway
    gateway_id = aws_internet_gateway.myapp-internet-gateway.id
  }
  tags = {
    Name = "${var.env_prefix}-router-table"
  }
}

# associate the subnet to a route table
resource "aws_route_table_association" "associate-rtbl-subnet" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-router-table.id
}



# resource "aws_security_group" "myapp-security-group" {
#   name        = "myapp-security-group"
#   description = "Allow TLS inbound traffic"
#   vpc_id      = aws_vpc.myapp-vpc.id    #so the servers in the vpc can be associated weith the secuerity group

# 		 #so ingress block handles the incoming requests/traffics to access the resources in the VPC such as accessing the ec2 instance from your CLI 0r accessing the nginx on port 8080 on port 22. in these cases we are sending traffic/requests to the VPC to access the EC2 instance or the nginx in it
#   #rules to expose port 22 for aceessing ec2 instance ourside
#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = [var.my-ip]
#   }
# #rules to expose port 22 for aceessing ec2 instance ourside
#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"] # expose to all ips sice is for all user
#   }
# # the egress block handles rules for our resource within the vpc making requests or sending trafic outside the vpc to the internet. examples of such traffic is like when you want to install docker or other package in your EC2 instance, the binaries needs to be fectched or downloaded from the internet. another example, when we run an nginx image, the images has to be fetched from the dockerhub. these are requests made by the ec2 from your vpc to the internet  
#   egress {
#     from_port        = 0 # not restricting the request to any port out there is to set the value to 0
#     to_port          = 0 #same here
#     protocol         = "-1"  # not to restricct the protocal to a particular ones, we set this to "any" by using -1
#     cidr_blocks      = ["0.0.0.0/0"]  # any ip address out there
#   }

#   tags = {
#      Name = "${var.env_prefix}-custom-security-group"
#   }
# }


resource "aws_default_security_group" "myapp-default-security-group" {
  
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
    description      = "Open port 8080 for access of the nginx server in the ec2 instance from a browser "
    from_port        = 8080
    to_port          = 8080
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
    Name = "${var.env_prefix}-default-security-group"
  }
}


resource "aws_key_pair" "myapp-key-pair" {
  key_name   = "myapp-key-pair"
  public_key = file(var.public_key_location)
  
  tags = {
    Name = "${var.env_prefix}-key_pair"
  }
}


resource "aws_instance" "myapp-EC2-instance" {
  ami           = "ami-0989fb15ce71ba39e" # for eu-north-1
  instance_type = "t3.micro"

  # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
subnet_id     =  aws_subnet.myapp-subnet-1.id
vpc_security_group_ids    = [aws_default_security_group.myapp-default-security-group.id]
availability_zone    = var.avail_zone

associate_public_ip_address    = true # to make sure public ip is display
key_name     = aws_key_pair.myapp-key-pair.key_name #stating that we are using an a keypair generated above


user_data = file("docker-container.sh") #handles instalation of docker on ec2 instance and running nginx on it


 tags = {
    Name = "${var.env_prefix}-myapp-EC2-instance"
  }
}

