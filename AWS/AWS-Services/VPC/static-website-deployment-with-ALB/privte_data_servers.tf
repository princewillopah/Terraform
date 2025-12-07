# resource "aws_instance" "data-Server1" {
#   ami           = "ami-0ecb62995f68bb549" # for us-east-1
#   instance_type = "t3.micro"


#   # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
#   subnet_id     =  var.data_subnets[0]
#   vpc_security_group_ids    = [aws_security_group.data-tier-security-group.id]
#   iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
#   # key_name               = "Princewill-ssh-bayero-sub" # to be used by web server to access app server via ssh


#  root_block_device {
#     volume_size = 20
#     volume_type = "gp3"
#   }

#  tags = {
#     Name = "Data-EC2"
#   }
# }



# resource "aws_instance" "data-Server2" {
#   ami           = "ami-0ecb62995f68bb549" # for us-east-1
#   instance_type = "t3.micro"


#   # if we do not specify the vpc subnets info here, the ec2 instance will be situated in the default VPC that came with the account 
#   subnet_id     =  var.data_subnets[1]
#   vpc_security_group_ids    = [aws_security_group.data-tier-security-group.id]
#   iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
#   # key_name               = "Princewill-ssh-bayero-sub" # to be used by web server to access app server via ssh


#  root_block_device {
#     volume_size = 20
#     volume_type = "gp3"
#   }

#  tags = {
#     Name = "Data-EC2"
#   }
# }