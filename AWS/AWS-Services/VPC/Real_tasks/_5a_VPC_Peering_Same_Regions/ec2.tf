resource "aws_instance" "a_public_ec2" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.a_public.id
  vpc_security_group_ids = [aws_security_group.allow_internal_a.id]
  associate_public_ip_address    = true
   key_name               = "Princewill-ssh-bayero-sub"
   tags = {
    Name = "VPC_A_Public_EC2"
    }
}

resource "aws_instance" "a_private_ec2" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.a_private.id
  vpc_security_group_ids = [aws_security_group.allow_internal_a.id]
   key_name               = "Princewill-ssh-bayero-sub"
    tags = {
     Name = "VPC_A_Private_EC2"
     }
}

resource "aws_instance" "b_public_ec2" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.b_public.id
  vpc_security_group_ids = [aws_security_group.allow_internal_b.id]
   key_name               = "Princewill-ssh-bayero-sub"
  associate_public_ip_address    = true
    tags = {
     Name = "VPC_B_Public_EC2"
     }
}
resource "aws_instance" "b_private_ec2" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.b_private.id
  vpc_security_group_ids = [aws_security_group.allow_internal_b.id]
   key_name               = "Princewill-ssh-bayero-sub"
    tags = {
     Name = "VPC_B_Private_EC2"
     }
}

resource "aws_instance" "c_public_ec2" {
  ami                    = "ami-0ecb62995f68bb549"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.c_public.id
  vpc_security_group_ids = [aws_security_group.allow_internal_c.id]
   key_name               = "Princewill-ssh-bayero-sub"
    associate_public_ip_address    = true
        tags = {
         Name = "VPC_C_Public_EC2"
         }
}
resource "aws_instance" "c_private_ec2" {
  ami                    = "ami-0ecb62995f68bb549"      
    instance_type          = "t3.micro"
    subnet_id              = aws_subnet.c_private.id
    vpc_security_group_ids = [aws_security_group.allow_internal_c.id]
    key_name               = "Princewill-ssh-bayero-sub"
        tags = {
         Name = "VPC_C_Private_EC2"
         }
}   
 



