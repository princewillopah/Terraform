variable "ami" {type = string }

variable "instance_type" {type = string }

variable "key_name" { type = string }

variable "instance_name" { type = string }  # custom

variable "volume_size" {type = number}

variable "region" {type = string}

variable "vpc_id" { type = string }

variable "subnet_id" { type = string }

variable "security_group_inbound_exposed_ports" {
  description = "List of allowed ingress ports"
  type        = list(number)
  default     = [22, 80]  # sensible defaults
}

variable "allowed_ssh_cidr_block" {  # custom
    type = string
    default = "0.0.0.0/0"  # Restrict in prod!
 }

variable "user_data" {
    type = string
    default = ""
}

 






# variable "volume_type" {
#   description = "The type of volume (e.g., gp2, io1)"
#   type        = string
#   default     = "gp2"
# }

# variable "subnet_id" {
#   description = "The subnet ID to launch the instance in"
#   type        = string
#   default     = 
# }


