variable "public_subnet_cidr" {
   description="CIDR block for the public subnet."
   default     = "10.0.1.0/24"
}
variable "instance_type" { 
   description="EC2 instance type."
   default="t3.micro"
}
variable "public_ami" { 
   description="AMI ID for public instances."
    default="ami-0914547665e6a707c"
}

variable "vpc_id" {}
variable "environment" {}
variable "key_name" { }