###############################################################################
# EC2 INSTANCES
#
# 1. Bastion Host  — public subnet, SSH from your IP → SSH tunnel to RDS
# 2. App EC2       — private subnet, connects to RDS directly
###############################################################################

# ─── Latest Amazon Linux 2023 AMI ─────────────────────────────────────────────
# This automatically picks the latest AMI so you don't hardcode an AMI ID.

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



# ─── App EC2 Instance ─────────────────────────────────────────────────────────
# Your application server in the PRIVATE subnet.
# No public IP — only reachable via the Bastion.

resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = aws_subnet.private[0].id


  vpc_security_group_ids = [aws_security_group.app.id]
  
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  
  associate_public_ip_address = false # Ensure no public IP is assigned. it is optional to set this since our private subnet has map_public_ip_on_launch = false, but we set it here for extra safety.
  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # Install postgres client on the app server too
    user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y postgresql-client
  EOF

  tags = {
    Name        = "${var.project_name}-app"
    Environment = var.environment
    Role        = "app"
  }
}
