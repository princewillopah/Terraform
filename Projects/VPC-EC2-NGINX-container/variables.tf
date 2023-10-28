variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
    description = ""
}

variable "subnet_cidr_block" {
     default = "10.0.1.0/24"
     description = ""
}
variable "avail_zone" {
     default = "eu-north-1a"
     description = ""
}
variable "env_prefix" {
     default = "Myapp-Dev-Env"
     description = ""
}
variable "my-ip" {
    default = "102.89.40.191/32"
}
variable "public_key_location" {
    default = "/home/princewillopah/.ssh/id_rsa.pub"
}

