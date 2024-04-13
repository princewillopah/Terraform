variable "EKS-SG" { 
   description = "Security group for the eks"
   type = string
}
variable "EKS-VPC-ID" {
   description = "VPC for the EKS"
   type = string
}
variable "EKS-Subnet-IDs" {
  description = "Ids to be specified in the EKS"
   type = list
}