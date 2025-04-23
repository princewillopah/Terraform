# output "vpc_id" {
#   value       = module.vpc.vpc_id
#   description ="The ID of the VPC."
# }

output "connectivity_for_provider_public_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem -o StrictHostKeyChecking=no ubuntu@${module.ProviderVPC.provider_public_instance_ip}"
}

output "connectivity_for_provider_private_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem -o StrictHostKeyChecking=no ubuntu@${module.ProviderVPC.provider_private_instance_ip}"
}



output "connectivity_for_consumer_public_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem -o StrictHostKeyChecking=no ubuntu@${module.ConsumerVPC.consumer_public_instance_ip}"
}
output "connectivity_for_consumer_private_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem -o StrictHostKeyChecking=no ubuntu@${module.ConsumerVPC.consumer_private_instance_ip}"
}
