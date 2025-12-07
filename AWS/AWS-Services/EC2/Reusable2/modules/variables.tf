variable "region" {
  description = "AWS region"
  type        = string
}

variable "instances" {
  description = "Map of EC2 instance configurations"
  type = map(object({
    subnet_id           = string
    ami_id              = string
    instance_type       = string
    key_name            = optional(string, null)
    iam_instance_profile = optional(string, null)
    user_data           = optional(string, null)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to attach to all instances"
  type        = list(string)
  default     = []
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30
}