# resource "aws_security_group" "vpce" {
#   name   = "${var.project_name}-vpce-sg"
#   vpc_id = aws_vpc.main.id

#   ingress {
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     security_groups = [aws_security_group.app.id]
#   }


#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# REQUIRED VPC ENDPOINTS SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [aws_security_group.vpce.id]

  private_dns_enabled = true
}

# SSM Messages
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [aws_security_group.vpce.id]

  private_dns_enabled = true
}

# EC2 Messages
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [aws_security_group.vpce.id]

  private_dns_enabled = true
}


# # S3 Gateway Endpoint - optional but recommended for better performance and security when accessing S3 from private subnets. It allows your EC2 instances to access S3( for patching, ssm packages, artifacts etc) without going through the internet, which is more secure and can be faster.
# resource "aws_vpc_endpoint" "s3" {
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.${var.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"

#   route_table_ids = aws_route_table.private[*].id
# }

# ---------------------------------------
# ECR Endpoints - Needed for Docker pulls.
# ----------------------------------------

# # ECR API Endpoint
# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.us-east-1.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private[*].id
#   security_group_ids  = [aws_security_group.vpce.id]
#   private_dns_enabled = true
# }


## ECR Docker Endpoint
# resource "aws_vpc_endpoint" "ecr_dkr" {
#   vpc_id              = aws_vpc.main.id
#   service_name        = "com.amazonaws.us-east-1.ecr.dkr"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = aws_subnet.private[*].id
#   security_group_ids  = [aws_security_group.vpce.id]
#   private_dns_enabled = true
# }

