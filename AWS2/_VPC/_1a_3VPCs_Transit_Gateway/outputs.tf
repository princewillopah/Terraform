# output "vpc_id" {
#   value       = module.vpc.vpc_id
#   description ="The ID of the VPC."
# }

output "connectivity_for_vpc_A_public_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.vpcA.vpc_A_public_instance_ip}"
}

output "connectivity_for_vpc_A_private_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.vpcA.vpc_A_private_instance_ip}"
}

output "connectivity_for_vpc_B_private_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.vpcB.vpc_B_private_instance_ip}"
}
output "connectivity_for_vpc_C_private_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.vpcC.vpc_C_private_instance_ip}"
}