# variable "name" {
#   description = "Base name for EC2 IAM role and instance profile"
#   type        = string
# }
variable "app_name" {}
# variable "attach_ssm" {
#   description = "Whether to attach AmazonSSMManagedInstanceCore"
#   type        = bool
#   default     = true
# }
# variable "attach_cloudwatch" {
#   description = "Whether to attach CloudWatchAgentServerPolicy"
#   type        = bool
#   default     = true
# }