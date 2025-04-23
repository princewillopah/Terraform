output "vpc_id" {
  value       = module.vpc.vpc_id
  description ="The ID of the VPC."
}

output "public_instance_ip" {
  value       = module.public_subnet.public_instance_ip
  description ="Public IP of the public instance."
}

output "private_instance_id" {
  value       = module.private_subnet.private_instance_id
  description ="ID of the private instance."
}