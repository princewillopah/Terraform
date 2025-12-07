provider "aws" {
  region = var.region
}

resource "aws_instance" "ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id      # Required: Subnet for placement
  key_name      = var.key_name

  # Use tags to help identify your resources
  tags = {
    Name = var.instance_name
  }

  # Attach a security group
  vpc_security_group_ids = [aws_security_group.shared-security-group.id]

  associate_public_ip_address = true # to make sure public ip is display
  user_data = var.user_data  # Bootstrap script (e.g., install packages)

  # Configure block devices (optional)
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  # Optional: Specify subnet
#   subnet_id = var.subnet_id
}

# output "instance_id" {
#   value = aws_instance.ec2.id
# }

# output "instance_public_ip" {
#   value = aws_instance.ec2.public_ip
# }
