# output "vpc_id" {
#   value       = module.vpc.vpc_id
#   description ="The ID of the VPC."
# }


output "connectivity_for__public_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.public_subnet.public_instance_ip}"
}

output "connectivity_for_private_instance" {
  value       = "ssh -i ~/.ssh/main-ssh-key.pem ubuntu@${module.private_subnet.private_instance_ip}"
}

output "s3_urls" {
  value       = module.my-s3.bucket_urls
}