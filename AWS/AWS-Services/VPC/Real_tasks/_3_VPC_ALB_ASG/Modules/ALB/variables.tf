variable "app_name" {}
variable "vpc_id" {}

variable "public_subnet_ids" {
  type = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type    = string
  default = null

}

variable "app_port" {
  default = 80
}
