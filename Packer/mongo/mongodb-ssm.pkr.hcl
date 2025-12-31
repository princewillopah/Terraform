# mongodb-ssm.pkr.hcl

packer {
  required_plugins {
    amazon = {
      version = "~> 1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# ----- Variables -----
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "source_ami_filter_name" {
  type    = string
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

# ----- Data Source: Find latest Ubuntu 22.04 AMI -----
data "amazon-ami" "ubuntu" {
  filters = {
    name                = var.source_ami_filter_name
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  owners      = ["099720109477"] # Canonical
  most_recent = true
  region      = var.aws_region
}

# ----- Source -----
source "amazon-ebs" "mongodb_ssm" {
  region        = var.aws_region
  source_ami    = data.amazon-ami.ubuntu.id
  instance_type = var.instance_type
  ssh_username  = "ubuntu"

  # Required for SSM: enable IMDSv2
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  # Temporary IAM instance profile for SSM access during build
  iam_instance_profile = "ssm-instance-profile"

  # Tags for the AMI
  ami_name    = "mongodb-ssm-ubuntu-22.04-{{timestamp}}"
  ami_regions = []

  # Optional: Encrypt root volume
  # ami_ebs_encrypted = true
}

# ----- Build -----
build {
  name = "mongodb-ssm-ami"
  sources = ["source.amazon-ebs.mongodb_ssm"]

  # --- Provisioner: Install SSM Agent (Ubuntu 22.04 already includes it, but ensure it's running)
  provisioner "shell" {
    inline = [
      # Install SSM Agent (required on Ubuntu)
      "sudo snap install amazon-ssm-agent --classic",

      # OR (alternative using .deb package):
      # "wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/ubuntu_amd64/amazon-ssm-agent.deb",
      # "sudo dpkg -i amazon-ssm-agent.deb",

      # Ensure it's running
      "sudo systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service",
      "sudo systemctl is-active --quiet snap.amazon-ssm-agent.amazon-ssm-agent.service && echo 'SSM Agent is running'"
    ]
  }

  # --- Provisioner: Install MongoDB
  provisioner "shell" {
    inline = [
      # Import MongoDB public GPG key
      "wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg",

      # Add MongoDB repo
      "echo 'deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list",

      # Update & install MongoDB
      "sudo apt-get update",
      "sudo apt-get install -y mongodb-org",

      # Start and enable MongoDB
      "sudo systemctl enable mongod",
      "sudo systemctl start mongod",

      # Wait for MongoDB to be ready
      "until sudo systemctl is-active --quiet mongod; do sleep 2; done",
      "echo 'MongoDB installed and running'"
    ]
  }

  # --- Optional: Harden MongoDB (basic)
  provisioner "shell" {
    inline = [
      "sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf",
      "sudo systemctl restart mongod"
    ]
    # ⚠️ WARNING: Binding to 0.0.0.0 exposes MongoDB to the network.
    # In production, restrict access via security groups or use VPC.
  }

  # --- Post-processor: Tag AMI
  post-processor "manifest" {
    output = "manifest.json"
  }
}