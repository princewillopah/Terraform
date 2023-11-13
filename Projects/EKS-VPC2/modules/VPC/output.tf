
# we need the output to be exported so the other modules that need it can use it 
# output "my-main-vpc-output" {
#    value = aws_vpc.EKS_VPC  #we are exporting the whole object of the subnet so the ec2 instace module can reference it in it  configuration
# }

# # Output the subnet IDs
# output "public_subnet_ids" {
#   value = aws_subnet.public_subnets[*].id
# }

# output "private_subnet_ids" {
#   value = aws_subnet.private_subnets[*].id
# }

# output "output-node-group-sg" {
#   value =  aws_security_group.ng-sg
# }


output "vpc_id" {
  value = aws_vpc.EKS_VPC.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "eks_worker_nodes_sg_id" {
  value = aws_security_group.ng-sg.id
}

