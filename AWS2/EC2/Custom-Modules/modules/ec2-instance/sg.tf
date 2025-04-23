resource "aws_security_group" "ec2-security-group" {
  name        = "Jenkins-Security Group"
  description = "Open 22,443,80,8080,9000,8086,9090,5000"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22,25, 80, 443,465, 8080, 8081, 9000, 3000, 5000, 8086, 9090] : {
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
    Name = "${var.instance_name}--security-group"
  }
}
