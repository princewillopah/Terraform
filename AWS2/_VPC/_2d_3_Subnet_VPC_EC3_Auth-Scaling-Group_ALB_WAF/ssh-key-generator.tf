resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default = "Temp-EKS-bootstrap-server-sshkey"
}

variable "home_directory" {
  description = "The user's home directory"
  default = "C:/Users/PB/.ssh"
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
