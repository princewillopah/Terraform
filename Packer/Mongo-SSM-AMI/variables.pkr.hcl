variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_id" {}
variable "subnet_id" {}

variable "instance_profile" {
  description = "IAM role with AmazonSSMManagedInstanceCore"
}