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

  tags = {
    Name = "myapp-vpc"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.avail_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-example"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.myapp-vpc.id
}


resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.public_RT.id
}



# resource "aws_security_group" "main" {
#   vpc_id = aws_vpc.myapp-vpc.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["192.168.167.30/32"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


## ===========================================================================================================================
## # Explanation
## ===========================================================================================================================

# This Terraform code defines an AWS subnet resource with specific attributes. 
# Each line configures different properties of the subnet. Let's break down the code in detail:

# resource "aws_subnet" "public" {
#   count                   = 3
#   vpc_id                  = aws_vpc.myapp-vpc.id
#   cidr_block              = cidrsubnet(aws_vpc.myapp-vpc.cidr_block, 3, count.index)
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
# vpc_id = aws_vpc.myapp-vpc.id:

# This assigns the ID of the VPC (Virtual Private Cloud) to which the subnets will belong.
# aws_vpc.myapp-vpc.id references the id attribute of a VPC resource named main.
# cidr_block = cidrsubnet(aws_vpc.myapp-vpc.cidr_block, 3, count.index):

# This uses the cidrsubnet function to calculate the CIDR block for each subnet.
# aws_vpc.myapp-vpc.cidr_block: The base CIDR block of the VPC.
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