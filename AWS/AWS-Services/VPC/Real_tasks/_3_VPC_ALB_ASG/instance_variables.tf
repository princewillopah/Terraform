variable "my_ip" {}
# variable "vpc_id" {}
# variable "public_subnet_ids" {}

# # -------------------------------------------------
# # Variables for subnets
# # -------------------------------------------------
variable "public_subnets_vars" {
  type = map(object({
    az          = string
    cidr_index  = number
  }))
#   default = {
#     az1 = { az = "us-east-1a", cidr_index = 0 }
#     az2 = { az = "us-east-1b", cidr_index = 1 }
#   }
}