variable "user_name" {
 description = "my username"
 default     = "princewillopah"
}
variable "avail_zone" {
 description = "Availability Zones"
 default     = "europe-west1"
}
variable "ssh-private-key" {
 description = "private key location"
 default     = "/home/princewillopah/.ssh/id_rsa"
}
