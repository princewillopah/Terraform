# we need the output to be exported so the other modules that need it can use it 
output "my-main-vpc-output" {
   value = aws_vpc.myEKS-vpc  #we are exporting the whole object of the subnet so the ec2 instace module can reference it in it  configuration
}


output "my-main-subnet-output1" {
   value = aws_subnet.myEKS-subnet-1  #we are exporting the whole object of the subnet so the ec2 instace module can reference it in it  configuration
}

output "my-main-subnet-output2" {
   value = aws_subnet.myEKS-subnet-2  #we are exporting the whole object of the subnet so the ec2 instace module can reference it in it  configuration
}