packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  region        = "us-east-1"
  instance_type = "t3.micro"
  ssh_username  = "ubuntu"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  ami_name = "ubuntu-base-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "scripts/ssm-script.sh"
    execute_command = "sudo -E bash '{{ .Path }}'" # Use sudo to run the script with elevated privileges so the script does not need sudo everywhere.
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
