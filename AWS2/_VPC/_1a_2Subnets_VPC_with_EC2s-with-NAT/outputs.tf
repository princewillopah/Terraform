output "vpc_id" {
  value       = module.vpc.vpc_id
  description ="The ID of the VPC."
}

output "public_instance_ip" {
  value       = module.my_public_subnet.public_instance_ip
  description ="Public IP of the public instance."
}
output "public_instance_connectivity" {

   value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.my_public_subnet.public_instance_ip}"
  description ="Public IP of the public instance."
}
output "my_private_instance_private_ip" {
  value       = module.private_subnet.private_instance_private_ip
  description ="ID of the private instance."
}
output "private_instance_connectivity" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.private_subnet.private_instance_private_ip}"
}