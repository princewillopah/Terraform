// To Generate Private Key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default = "temporal-ekc-bootstrap-server-sshkey"
}

variable "home_directory" {
  description = "The user's home directory"
  default = "~/.ssh"
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_4096.public_key_openssh
  tags = {
    Name = "${var.environment}-key_pair"
  }
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem
  filename = "${pathexpand(var.home_directory)}/${var.key_name}"
  provisioner "local-exec" {
    command = "chmod 400 ${pathexpand(var.home_directory)}/${var.key_name}"
  }
}

resource "aws_security_group" "ec2-security-group" {
  ingress {
    description      = "Open port 22 for CLI access to the EC2 instance"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "Open port 8080 for access to the nginx server"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "Open port 8081 for access to the nexus server"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description      = "Allow outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.environment}--security-group"
  }
}

resource "aws_instance" "my-Servers" {
  for_each      = { for idx, instance in var.instances : idx => instance }
  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name
  vpc_security_group_ids = [aws_security_group.ec2-security-group.id]

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name = each.value.name
    Environment = var.environment
  }
}
