
# # ---------------------------------------------------------------------
# # Data tier SG (no rules yet)
# # ---------------------------------------------------------------------
# resource "aws_security_group" "data_sg" {
#   name   = "data-sg"
#   vpc_id = aws_vpc.vpc.id
# }


# # ---------------------------------------------------------------------
# # VPC Endpoint SG (no rules yet)
# # ---------------------------------------------------------------------
# resource "aws_security_group" "ssm_vpce" {
#   name   = "ssm-vpce-sg"
#   vpc_id = aws_vpc.vpc.id
# }
# # ---------------------------------------------------------------------
# # Security Group Rules to allow Data Tier <> VPC Endpoint communication
# # ---------------------------------------------------------------------

# resource "aws_security_group_rule" "data_to_vpce_egress" {
#   type                     = "egress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"

#   security_group_id        = aws_security_group.data_sg.id
#   cidr_blocks = ["0.0.0.0/0"]
#   # source_security_group_id = aws_security_group.ssm_vpce.id

# }






# # ---------------------------------------------------------------------
# #   Security Group Rules to allow VPC Endpoint <> Data Tier communication
# # ---------------------------------------------------------------------
# resource "aws_security_group_rule" "vpce_from_data_ingress" {
#   type                     = "ingress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"

#   security_group_id        = aws_security_group.ssm_vpce.id
#   source_security_group_id = aws_security_group.data_sg.id
# }


# resource "aws_security_group_rule" "vpce_egress_all" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.ssm_vpce.id
# }

# # This approach help to avoid dependency issues when creating security groups and their rules
# # because the security groups below has dependency issue thus leading to "Error: Cycle: aws_security_group.data_sg, aws_security_group.ssm_vpce"
# # since "data_sg" and "ssm_vpce"depend on each other to create their rules.






# ---------------------------------------------------------------------
# Data tier SG (NO internet dependency) (DATA TIER ONLY)
# ---------------------------------------------------------------------
resource "aws_security_group" "data_sg" {
  name   = "data-sg"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

# # ---------------------------------------------------------------------
# # Security Group for VPC Endpoint Security Group (DATA TIER ONLY)
# # ---------------------------------------------------------------------

resource "aws_security_group" "ssm_vpce" {
  name   = "ssm-vpce-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.data_sg.id] # allows inbound connections from the Data SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# This SG allows instances in the EC2 SG to communicate with the VPC Endpoint over port 443
# ✔️ Allows Data EC2 → VPCE
