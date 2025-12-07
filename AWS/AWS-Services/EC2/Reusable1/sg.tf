


# resource "aws_security_group" "app_server_1_sg" {
#   name   = "app-server-1-sg"
#   description = "Security group for EC2 instance"
#   vpc_id = var.my_vpc_id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] 
#     }
#     ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     }
#     ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     }
#       egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "app-server-1-security-group"
#   }
# }

# resource "aws_security_group" "app_server_2_sg" {
#   name   = "app-server-2-sg"
#   vpc_id = var.my_vpc_id

#   ingress = [
#     for port in [22,25, 80, 443,465, 8080, 8081, 9000, 3000, 5000, 8086, 9090] : {
#       description      = "TLS from VPC"
#       from_port        = port
#       to_port          = port
#       protocol         = "tcp"
#       cidr_blocks      = ["0.0.0.0/0"]
#       ipv6_cidr_blocks = []
#       prefix_list_ids  = []
#       security_groups  = []
#       self             = false
#     }
#   ]
#     egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "app-server-2-security-group"
#   }
# }
