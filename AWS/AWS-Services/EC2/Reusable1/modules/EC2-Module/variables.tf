variable "instances" {
  description = "Map of EC2 instance configurations"
  type = map(object({
    ami                = string
    instance_type      = string
    subnet_id          = string
    key_name           = string
    security_groups    = list(string)
    associate_public_ip = optional(bool)
    root_volume_size    = optional(number)
    my_iam_instance_profile = optional(string, null)
    user_data           = optional(string, null)
    tags                = optional(map(string), {})
  }))
}
