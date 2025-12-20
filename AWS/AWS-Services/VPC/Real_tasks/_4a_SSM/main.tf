# ------------------------------------------------------------------------------
# VPC Module
# ------------------------------------------------------------------------------
module "vpc-module" {
  source = "./Modules/VPC"
  vpc_CIDR = var.vpc_cidr_block
  app_name = var.app_name
  public_subnets= var.public_subnets
  private_app_subnets = var.private_app_subnets
  private_data_subnets = var.private_data_subnets
  # instance_type = var.instance_type
  # ami_id = var.ami_id
}

# ------------------------------------------------------------------------------
# IAM Module
# ------------------------------------------------------------------------------
module "iam" {
  source = "./Modules/IAM"
  app_name = var.app_name
#   name   = "${var.app_name}-ec2-role"
#   attach_ssm = true
#   attach_cloudwatch = false
} 

# ------------------------------------------------------------------------------
# EC2 Instances Module
# ------------------------------------------------------------------------------

module "app_ec2" {
  source = "./Modules/Instances"

  role_name          = "app"
  app_name           = var.app_name
  env                = var.env

  ami_id             = var.app_ami
  instance_type      = var.app_instance_type
  key_name           = var.app_key_name        # OPTIONAL
  associate_public_ip = false                  # PROD DEFAULT

  subnet_map         = var.app_instances
  security_group_ids = [module.vpc.instance_sg]

  iam_instance_profile = module.iam.ssm_instance_profile
}






# module "ec2_fleet" {
#   source = "./Modules/Instances"

#   instances = {

#     web-tier-server1 = {
#       app_name          = var.app_name
#       ami                = var.ami_id
#       instance_type      = var.instance_type
#       subnet_id          = data.aws_subnet.private_app_1a.id
#       key_name           = "Princewill-ssh-bayero-sub"
#       security_groups    = [aws_security_group.app_server_1_sg.id]
#       associate_public_ip = true
#       root_volume_size    = 30
#       my_iam_instance_profile = module.iam.instance_profiles_output["app_server_role"]
#       tags = {
#         env  = "dev"
#         tier = "app"
#       }
#     }

#     web-tier-server2 = {
#       ami                 = "ami-0ecb62995f68bb549"
#       instance_type       = "t3.micro"
#       subnet_id           = data.aws_subnet.private_app_1b.id
#       key_name            = "Princewill-ssh-bayero-sub"
#       security_groups     = [aws_security_group.app_server_2_sg.id]
#       associate_public_ip = true
#       my_iam_instance_profile = module.iam.instance_profiles_output["db_server_role"]
#     }

#     # web-server-1 = {
#     #   ami                = "ami-0ecb62995f68bb549"
#     #   instance_type      = "t3.micro"
#     #   subnet_id          = aws_subnet.public_web_1a.id
#     #   key_name           = "my-key"
#     #   security_groups    = [aws_security_group.web_sg.id]
#     #   associate_public_ip = true
#     #   tags = {
#     #     env  = "dev"
#     #     tier = "web"
#     #   }
#     # }
#     # web-server-2 = {
#     #   ami                = "ami-0abcdef1234567890"  
#     #   instance_type      = "t3.micro"
#     #   subnet_id          = aws_subnet.public_web_1b.id
#     #   key_name           = "my-key"
#     #   security_groups    = [aws_security_group.web_sg.id]
#     #   associate_public_ip = true
#     # }
#    // more instances can be added here

#   }// the instance block ends here
# }
