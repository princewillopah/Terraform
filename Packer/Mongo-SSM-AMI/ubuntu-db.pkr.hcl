packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.8"
    }
  }
}

source "amazon-ebs" "ubuntu-db" {
  region              = var.aws_region
  instance_type       = "t3.micro"
  ssh_username        = "ubuntu"
  ami_name            = "ubuntu-db-base-{{timestamp}}"

  subnet_id            = var.subnet_id
  vpc_id               = var.vpc_id
  associate_public_ip_address = true

  iam_instance_profile = var.instance_profile

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical
    most_recent = true
  }

  tags = {
    Name = "ubuntu-db-base"
    Role = "database"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu-db"]

  provisioner "shell" {
    scripts = [
      "scripts/base.sh",
      "scripts/install_ssm.sh",
      "scripts/install_mongodb.sh",
      "scripts/install_mysql.sh"
    ]
  }
}