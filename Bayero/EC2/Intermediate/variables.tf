
variable "avail_zone" {
 description = "Availability Zones"
 default     = "us-east-1"
}

variable "ami-xxx" {
  description = "AMI ID"
  default     = "ami-0360c520857e3138f"
}
variable "environment" {
  description = "EKS-Bootstrap-Server"
 default     = "Dev"
}