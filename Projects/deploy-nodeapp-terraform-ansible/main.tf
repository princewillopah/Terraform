# Terraform block defines required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# AWS provider block configures AWS authentication
provider "aws" {
  region     = "AWS_REGION"   # Specify the AWS region for the provider
  access_key = "AWS_ACCESS_KEY"   # Specify your AWS access key
  secret_key = "AWS_SECRET_KEY"   # Specify your AWS secret key
}

# TLS Private Key resource generates an RSA private key
resource "tls_private_key" "rsa_4096" {
  algorithm = "RSA"  # Generate an RSA key
  rsa_bits  = 4096   # Key size of 4096 bits
}

# Variable block defines the SSH key pair name
variable "key_name" {
  description = "Name of the SSH key pair"
}

# AWS Key Pair resource creates an AWS key pair for SSH access
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name   # Use the SSH key pair name specified in the variable
  public_key = tls_private_key.rsa_4096.public_key_openssh  # Use the public key from the generated private key
}

# Local File resource saves the RSA private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_4096.private_key_pem  # Save the private key in PEM format
  filename = "~/.ssh/${var.key_name}"  # Save it in the SSH directory with the specified key name

  provisioner "local-exec" {
    command = "chmod 400 ~/.ssh/${var.key_name}"  # Set the correct file permissions on the private key
  }
}

# AWS Security Group resource creates a security group for EC2
resource "aws_security_group" "sg_ec2" {
  name        = "sg_ec2"   # Name of the security group
  description = "Security group for EC2"  # Description for the security group

  ingress {
    from_port   = 22   # Allow SSH traffic
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Allow SSH from anywhere
  }

  ingress {
    from_port   = 3000   # Allow traffic on port 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Allow traffic on port 3000 from anywhere
  }

  egress {
    from_port   = 0   # Allow all outbound traffic
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]   # Allow outbound traffic to anywhere
  }
}

# AWS Instance resource creates an EC2 instance
resource "aws_instance" "public_instance" {
  ami                    = "ami-0f5ee92e2d63afc18"   # AMI for the EC2 instance
  instance_type          = "t2.micro"   # EC2 instance type
  key_name               = aws_key_pair.key_pair.key_name  # SSH key pair to use
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]  # Attach the security group

  tags = {
    Name = "public_instance"
  }
  
  root_block_device {
    volume_size = 30   # Root volume size
    volume_type = "gp2"   # Root volume type
  }

  provisioner "local-exec" {
    command = "touch dynamic_inventory.ini"  # Create a file named dynamic_inventory.ini
  }
}

# Data template file defines an Ansible dynamic inventory
data "template_file" "inventory" {
  template = <<-EOT
    [ec2_instances]
    ${aws_instance.public_instance.public_ip} ansible_user=ubuntu ansible_private_key_file=${path.module}/${var.key_name}
    EOT
}

# Local File resource saves the dynamic inventory template
resource "local_file" "dynamic_inventory" {
  depends_on = [aws_instance.public_instance]  # Depend on the EC2 instance creation

  filename = "dynamic_inventory.ini"   # Name of the dynamic inventory file
  content  = data.template_file.inventory.rendered  # Use the rendered template

  provisioner "local-exec" {
    command = "chmod 400 ${local_file.dynamic_inventory.filename}"  # Set file permissions
  }
}

# Null Resource triggers Ansible playbook execution
resource "null_resource" "run_ansible" {
  depends_on = [local_file.dynamic_inventory]  # Depend on the dynamic inventory file

  provisioner "local-exec" {
    command = "ansible-playbook -i dynamic_inventory.ini deploy-app.yml"  # Run the Ansible playbook
    working_dir = path.module   # Use the module's directory as the working directory
  }
}
