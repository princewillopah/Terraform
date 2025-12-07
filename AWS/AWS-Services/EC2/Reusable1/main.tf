
# Currently we have just 2 roles(app_server_role and db_server_role). we can add more roles and policies as needed.
# note that a service can only be assigned a role and not more than one role






module "iam" {
  source = "./modules/IAM-Module"

  roles = {
    app_server_role = {
      policies = [
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
            "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]
    }// app_server_role ends here

    db_server_role = {
      policies = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
         "arn:aws:iam::aws:policy/AmazonS3FullAccess",
          "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
         "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ] // you can add more policies or remove policies as needed and then run the apply command again to effect the changes
    }// db_server_role ends here
  }
}


module "ec2_fleet" {
  source = "./modules/EC2-Module"

  instances = {

    # app-server-1 = {
    #   ami                = "ami-0ecb62995f68bb549"
    #   instance_type      = "t3.micro"
    #   subnet_id          = data.aws_subnet.private_app_1a.id
    #   key_name           = "Princewill-ssh-bayero-sub"
    #   security_groups    = [aws_security_group.app_server_1_sg.id]
    #   associate_public_ip = true
    #   root_volume_size    = 30
    #   my_iam_instance_profile = module.iam.instance_profiles_output["app_server_role"]
    #   tags = {
    #     env  = "dev"
    #     tier = "app"
    #   }
    # }

    # app-server-2 = {
    #   ami                 = "ami-0ecb62995f68bb549"
    #   instance_type       = "t3.micro"
    #   subnet_id           = data.aws_subnet.private_app_1b.id
    #   key_name            = "Princewill-ssh-bayero-sub"
    #   security_groups     = [aws_security_group.app_server_2_sg.id]
    #   associate_public_ip = true
    #   my_iam_instance_profile = module.iam.instance_profiles_output["db_server_role"]
    # }

    # web-server-1 = {
    #   ami                = "ami-0ecb62995f68bb549"
    #   instance_type      = "t3.micro"
    #   subnet_id          = aws_subnet.public_web_1a.id
    #   key_name           = "my-key"
    #   security_groups    = [aws_security_group.web_sg.id]
    #   associate_public_ip = true
    #   tags = {
    #     env  = "dev"
    #     tier = "web"
    #   }
    # }
    # web-server-2 = {
    #   ami                = "ami-0abcdef1234567890"  
    #   instance_type      = "t3.micro"
    #   subnet_id          = aws_subnet.public_web_1b.id
    #   key_name           = "my-key"
    #   security_groups    = [aws_security_group.web_sg.id]
    #   associate_public_ip = true
    # }
   // more instances can be added here

  }// the instance block ends here
}




///////////////////////////////////////////////////////////////////////////
# Add more ARNs to the role’s policies list
# Re-run terraform apply
# The module will:
# - Attach additional permissions
# - NOT recreate EC2
# - NOT destroy IAM roles
# EC2 instance immediately gains access via metadata service