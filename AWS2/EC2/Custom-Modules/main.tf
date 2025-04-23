provider "aws" {
  region = var.region
}

module "ec2" {
  source            = "./modules/ec2-instance"
  ami               = var.ami
  instance_type     = var.instance_type
  key_name          = var.key_name
  instance_name     = var.instance_name
  security_group_ids = var.security_group_ids
  subnet_id         = var.subnet_id
  volume_size       = var.volume_size
  volume_type       = var.volume_type
  region            = var.region
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "ec2_instance_public_ip" {
  value = module.ec2.instance_public_ip
}
