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
  name = "golden-ubuntu"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "scripts/ssm-script.sh"
    execute_command = "sudo -E bash '{{ .Path }}'" # Use sudo to run the script with elevated privileges so the script does not need sudo everywhere.
  }

  # --- Post-processor: Tag AMI
  post-processor "manifest" {
    output = "manifest.json"
  }
}
