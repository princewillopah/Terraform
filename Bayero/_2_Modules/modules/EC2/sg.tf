resource "aws_security_group" "shared-security-group" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name}"
  vpc_id      = var.vpc_id  # Required: VPC ID for network placement
  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in var.security_group_inbound_exposed_ports : {
      description      = "Allow TCP ${port}"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = [var.allowed_ssh_cidr_block]//["0.0.0.0/0"]
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
    Name = "${var.instance_name}--security-group"
  }
}
