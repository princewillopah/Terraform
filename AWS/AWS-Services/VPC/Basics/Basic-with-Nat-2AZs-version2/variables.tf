variable "public_subnets" {
  type = map(string)
  default = {
    us-east-1a = "10.5.1.0/24"
    us-east-1b = "10.5.4.0/24"
  }
}
