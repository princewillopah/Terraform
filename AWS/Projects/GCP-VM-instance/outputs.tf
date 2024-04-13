# output "public_ip" {
#   value = google_compute_address.static_ip.address
# }


# output "public_ip" {
#   value = google_compute_instance.my_instance.network_interface.0.access_config.0.assigned_nat_ip
# }

# output "private_key_path" {
#   value = tls_private_key.my_ssh_key.private_key_pem
# }

output "public_ip" {
  value = google_compute_instance.server1.network_interface.0.access_config.0.nat_ip
}
