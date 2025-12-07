provider "aws" {
  region = var.region
}

module "ec2_instances" {
  source = "./modules/ec2-multi"

  region                  = var.region
  vpc_security_group_ids  = var.vpc_security_group_ids
  root_volume_size        = 20

  instances = {
    web-server-1 = {
      subnet_id      = "subnet-0a1b2c3d4e5f6g7h8"  # e.g., us-east-1a
      ami_id         = "ami-0abcdef1234567890"       # Amazon Linux 2023
      instance_type  = "t3.micro"
      key_name       = "your-key-pair"
      tags = {
        Role = "web"
        Env  = "prod"
      }
    },
    app-server-1 = {
      subnet_id      = "subnet-1a2b3c4d5e6f7g8h9"  # e.g., us-east-1b
      ami_id         = "ami-0abcdef1234567890"
      instance_type  = "t3.small"
      key_name       = "your-key-pair"
      user_data      = base64encode("#!/bin/bash\necho 'Hello from app-server' > /tmp/hello.txt")
      tags = {
        Role = "app"
        Env  = "prod"
      }
    }
    # Add more instances here later as needed
  }
}