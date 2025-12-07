## ----------------------------------------------------------------
## Terraform and provder block
## ----------------------------------------------------------------

# provider "aws" {
#   region = var.region
# }

## ----------------------------------------------------------------
## Variable Block
## ----------------------------------------------------------------

# variable "ami" {
#   description = "The AMI ID to use for the EC2 instance"
#   type        = string
#   default     = "ami-12345678"  # Replace with the actual AMI ID
# }

# variable "instance_type" {
#   description = "The instance type"
#   type        = string
#   default     = "t2.micro"
# }

# variable "key_name" {
#   description = "The name of the SSH key pair"
#   type        = string
# }

# variable "instance_name" {
#   description = "Name tag for the EC2 instance"
#   type        = string
#   default     = "example-instance"
# }

# variable "security_group_ids" {
#   description = "Security group IDs for the instance"
#   type        = list(string)
# }

# variable "subnet_id" {
#   description = "The subnet ID for the EC2 instance"
#   type        = string
# }

# variable "volume_size" {
#   description = "Size of the EBS volume"
#   type        = number
#   default     = 10
# }

# variable "volume_type" {
#   description = "Type of EBS volume"
#   type        = string
#   default     = "gp2"
# }

# variable "region" {
#   description = "AWS region"
#   type        = string
#   default     = "eu-north-1"
# }

## ----------------------------------------------------------------
## Main resourc Block
## ----------------------------------------------------------------

module "frontend" {
  source                                = "./modules/EC2"
  ami                                   = "ami-0360c520857e3138f"
  instance_type                         = "t3.micro"
  key_name                              = "prince-bayero-ssh"
  instance_name                         = "Frontend"
  security_group_inbound_exposed_ports  = [22, 80, 443, 8080, 9000, 5000]
  allowed_ssh_cidr_block                = "203.0.113.0/24"  # Your laptop IP  //allowed_ssh_cidr_block is a custom variable
  volume_size                           = 30
  region                                = "us-east-1"
  vpc_id                                = "vpc-0a453a0a985c3d7a0"
  subnet_id                             = "subnet-0ccf70adec7e3f621"
  user_data                             = file("user-data.sh")  # Bootstrap script (optional)
}

module "backend" {
  source                                = "./modules/EC2"
  ami                                   = "ami-0360c520857e3138f"
  instance_type                         = "t3.micro"
  key_name                              = "prince-bayero-ssh"
  instance_name                         = "backend"
  security_group_inbound_exposed_ports  = [22, 80, 443, 8080]
  allowed_ssh_cidr_block                = "203.0.113.0/24"  # Your laptop IP  //allowed_ssh_cidr_block is a custom variable
  volume_size                           = 20
  region                                = "us-east-1"
  vpc_id                                = "vpc-0a453a0a985c3d7a0"
  subnet_id                             = "subnet-0ccf70adec7e3f621"
  user_data                             = file("user-data.sh")  # Bootstrap script (optional)
}

# module "backend" {
#   source             = "./modules/EC2"
#   ami                = var.ami  # "ami-12345678
#   instance_type      = var.instance_type
#   key_name           = var.key_name
#   instance_name      = var.instance_name
#   security_group_ids = var.security_group_ids
#   subnet_id          = var.subnet_id
#   volume_size        = var.volume_size
#   region             = var.region
# }



## ----------------------------------------------------------------
## output block
## ----------------------------------------------------------------
output "frontend_instance" {
  value = {
    id        = module.ec2.instance_id
    public_ip = module.ec2.instance_public_ip
  }
}

output "backend_instance" {
  value = {
    id        = module.backend.instance_id
    public_ip = module.backend.instance_public_ip
  }
}

# ------- option 2----------------------------------
output "instances" {
  value = {
    for name, mod in {
      frontend = module.ec2
      backend  = module.backend
    } : name => {
      id        = mod.instance_id
      public_ip = mod.instance_public_ip
    }
  }
}
