


# -------------------------------------------------------------
## app Server EC2 Instance
# -------------------------------------------------------------
resource "aws_instance" "app_Server_1a" {
  ami           = var.ami # for us-east-1
  instance_type = var.instance_type

  subnet_id     =  aws_subnet.public_subnet_1a.id
  vpc_security_group_ids    = [aws_security_group.app-server-security-group.id]
  key_name               = var.key_name
associate_public_ip_address    = true
  # user_data = file("app-tier-user-data.sh")
  user_data = templatefile("${path.module}/app-tier-user-data.sh", {
        mongodb_private_ip = aws_instance.db_Server_1a.private_ip
   })
   iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device {
      volume_size = 20
      volume_type = "gp3"
    }
  
  tags = {
      Name = "${var.app_name}-App_Server_1a"
    }

    
  }




# -------------------------------------------------------------
## database Server EC2 Instance
# -------------------------------------------------------------


resource "aws_instance" "db_Server_1a" {
  ami           = var.ami # for us-east-1
  instance_type = var.instance_type

  subnet_id     =  aws_subnet.data_tier_subnet_1a.id
  vpc_security_group_ids    = [aws_security_group.db-server-security-group.id]
  key_name               = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

associate_public_ip_address    = false 
 user_data = file("db-tier-user-data.sh")
 root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

 tags = {
    Name = "${var.app_name}-DB_Server_1a"
  }
}