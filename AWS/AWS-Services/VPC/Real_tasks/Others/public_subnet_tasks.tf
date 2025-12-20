

# # ---------------------------------------
# # Create Public Subnets
# # ---------------------------------------
# resource "aws_subnet" "public_subnet_az1" {
#   vpc_id                  = aws_vpc.app_vpc.id
#   cidr_block              = cidrsubnet(var.vpc_CIDR, 8, 0)
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true    
#     tags = {
#         Name = "${var.app_name}-public-subnet-az1"
#     }
# }

# resource "aws_subnet" "public_subnet_az2" {
#   vpc_id                  = aws_vpc.app_vpc.id
#   cidr_block              = cidrsubnet(var.vpc_CIDR, 8, 1)
#   availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = true    
#     tags = {
#         Name = "${var.app_name}-public-subnet-az2"
#     }
# }
# # ---------------------------------------
# # Create Internet Gateway
# # ---------------------------------------
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.app_vpc.id
#     tags = {
#         Name = "${var.app_name}-igw"
#     }
# }
# # ---------------------------------------
# # Create Public Route Table
# # ---------------------------------------
# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.app_vpc.id
#     tags = {
#         Name = "${var.app_name}-public-rt"
#     }
# }
# # ---------------------------------------
# # Create Public Route to Internet Gateway
# # ---------------------------------------
# resource "aws_route" "public_internet_route" {
#   route_table_id         = aws_route_table.public_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.igw.id
# }   

# # ---------------------------------------
# # Associate Public Subnets with Public Route Table
# # ---------------------------------------
# resource "aws_route_table_association" "public_assoc_az1" {
#   subnet_id      = aws_subnet.public_subnet_az1.id
#   route_table_id = aws_route_table.public_rt.id
# }   
# resource "aws_route_table_association" "public_assoc_az2" {
#   subnet_id      = aws_subnet.public_subnet_az2.id
#   route_table_id = aws_route_table.public_rt.id
# }


