resource "aws_subnet" "private_subnet" { 
   vpc_id            = var.vpc_id 
   cidr_block        = var.private_subnet_cidr 

   tags              ={ 
      Name          ="${var.environment}-private-subnet"
   }
}

resource "aws_security_group" "private_sg" { 
   vpc_id          =(var.vpc_id)

   ingress { 
      from_port       =22 # SSH access.
      to_port         =22 
      protocol        ="tcp"
      # cidr_blocks     =[aws_security_group.public_sg.ingress[0].cidr_blocks[0]] # Allow SSH from the public subnet only.
       cidr_blocks = ["10.0.1.0/24"] # Allow SSH from the public subnet only.
  }

ingress {
    description      = "Allow ICMP - ping"
    from_port        = -1                  # For ICMP, from_port and to_port are -1
    to_port          = -1
    protocol         = "icmp"              # Protocol for ICMP
    cidr_blocks      = ["10.0.1.0/24"] # Only allow ICMP from the public EC2 instance's IP or a specific range
}
   egress { 
      from_port       =0 
      to_port         =0 
      protocol        ="-1"
      cidr_blocks     =["0.0.0.0/0"]
   }

   tags ={ 
      Name          ="${var.environment}-private-sg"
   }
}

resource "aws_instance" "private_instance" { 
   ami           =(var.private_ami) # You need to specify a valid AMI ID.
   instance_type =(var.instance_type)
  subnet_id         =(aws_subnet.private_subnet.id) 
  security_groups =[aws_security_group.private_sg.id]

   key_name      = var.key_name
   # Associate the instance profile with the existing instance
   iam_instance_profile = var.s3_access_instance_profile_name  #var.iam_module.s3_access_instance_profile_name

   user_data = file("install.sh") 
   tags ={ 
         Name          ="${var.environment}-private-instance"
   }
}

# output "private_instance_id"{ 
# value=aws_instance.private_instance.id 
# }