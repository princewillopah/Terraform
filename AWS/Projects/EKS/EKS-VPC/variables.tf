variable "avail_zone" {
  default  = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
  description = ""
}
variable "env_prefix" {
  default = "My-EKS-and-TF"
  description = ""
}
variable "SSH_public_key_location" {
    default = "/home/princewillopah_dev/.ssh/my_ssh_key_for_my_main_linux_ec2.pub"
}