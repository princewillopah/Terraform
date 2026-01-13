variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "cluster_name" {
  type    = string
  default = "eks-prod"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Owner       = "platform"
  }
}
