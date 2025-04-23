# we need the output to be exported so the other modules that need it can use it 
output "my-main-vpc-output" {
   value = aws_vpc.myapp-vpc  #we are exporting the whole object of the subnet so the ec2 instace module can reference it in it  configuration
}

#we are exporting the whole object of the subnet so the ec2 instace module can reference it in it  configuration
output "my-main-subnet-output" {
   value = aws_subnet.myapp-subnet-1  
}



