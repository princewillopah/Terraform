variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
    description = ""
}

# variable "subnet_cidr_block" {
#      default = "10.0.1.0/24"
#      description = ""
# }
# variable "avail_zone" {
#      default = "eu-north-1a"
#      description = ""
# }

# variable "env_prefix" {
#      default = "My-EKS-and-TF"
#      description = ""
# }

// Both values re comming from the main
variable "VPC_avail_zone" {}  // 
variable "VPC_env_prefix" {}  // 