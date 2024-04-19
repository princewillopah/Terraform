# variable "resource_group_location" {
#   type        = string
#   default     = "eastus"
#   description = "Location of the resource group."
# }

# variable "resource_group_name" {
#   type        = string
#   default     = "Prince-RG"
#   description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
# }

variable "env" {
  type        = string
  default     = "Project-x"
  description = "to determine the envrionment of the project"
}