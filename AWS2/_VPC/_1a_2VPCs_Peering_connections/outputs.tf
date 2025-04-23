# output "vpc_id" {
#   value       = module.vpc.vpc_id
#   description ="The ID of the VPC."
# }

output "connectivity_for_vpc_1_public_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.vpc1.vpc_1_public_instance_ip}"
}

output "connectivity_for_vpc_1_private_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.vpc1.vpc_1_private_instance_ip}"
}

output "connectivity_for_vpc_2_private_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.vpc2.vpc_2_private_instance_ip}"
}
