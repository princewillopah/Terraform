variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "project_name" {
  type        = string
  default     = "my-app"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  type = string
}
