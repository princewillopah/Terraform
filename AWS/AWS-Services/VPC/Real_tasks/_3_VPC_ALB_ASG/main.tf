

# ---------------------------------------
# VPC Module
# ---------------------------------------
module "vpc-module" {
  source = "./Modules/VPC"
  vpc_CIDR = var.vpc_cidr_block
  app_name = var.app_name
  public_subnets_vars = var.public_subnets_vars
  private_app_subnets_vars = var.private_app_subnets_vars
#   VPC_env_prefix = var.env_prefix
#   VPC_avail_zone = var.avail_zone
}

# ---------------------------------------
# IAM Module
# ---------------------------------------
module "iam" {
  source = "./Modules/IAM"
  name   = "${var.app_name}-ec2-role"
  attach_ssm = true
  attach_cloudwatch = false
} 

# ---------------------------------------
# Instance Module
# ---------------------------------------
module "instance-module" {
  source = "./Modules/Instances"
  app_name = var.app_name
  my_ip = var.my_ip
  app_vpc_id = module.vpc-module.vpc_id
  ami_id = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  public_subnet_az1 = module.vpc-module.public_subnet_az1_id
  iam_instance_profile = module.iam.instance_profile_name
#   public_subnets_vars = var.public_subnets_vars
#   private_app_subnets_vars = var.private_app_subnets_vars

}

# # ---------------------------------------
# # Auto Scaling Group Module
# # ---------------------------------------
module "app_asg" {
  source = "./Modules/ASG"

  app_name      = var.app_name
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  private_subnet_ids = module.vpc-module.private_app_subnet_ids
  # security_group_id  = "hgghs"
  app_vpc_id        = module.vpc-module.vpc_id/////////////////////////////////////
  iam_instance_profile_name =  module.iam.instance_profile_name

  desired_capacity = 2
  min_size         = 1
  max_size         = 3

  target_group_arn = module.app_alb.alb_target_group_arn

  app_port = 80
  jump_sg_id = module.instance-module.jump_sg_id
  alb_sg_id  = module.app_alb.alb_security_group_id
}



# # ---------------------------------------
# # ALB Module
# # ---------------------------------------
module "app_alb" {
  source = "./Modules/ALB"

  app_name          = var.app_name
  vpc_id            = module.vpc-module.vpc_id
  public_subnet_ids = module.vpc-module.public_subnet_ids  // we are using public subnets for ALB  // var.public_subnet_vars

  certificate_arn =  module.dns_module.certificate_arn //var.acm_certificate_arn  //module.dns_module.certificate_arn

}

# # ---------------------------------------
# # DNS Module
# # ---------------------------------------
module "dns_module" {
  source = "./Modules/DNS"
  app_name          = var.app_name
  domain_name       = var.domain_name
  # hosted_zone_id    = var.hosted_zone_id // we are using root zone so no need to pass this variable 
  alb_dns_name      = module.app_alb.alb_dns_name
  alb_zone_id       = module.app_alb.alb_zone_id

  # app_name = var.app_name
  # alb_dns_name = module.app_alb.alb_dns_name
}// 








# # ---------------------------------------
# # Outputs
# # ---------------------------------------
# output "vpc_id" {
#   value = module.vpc-module.vpc_id
# }

# output "instance_profile_name" {
#   value = module.iam.instance_profile_name
# }