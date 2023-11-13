output "availability_zone_names" {
  value = data.aws_availability_zones.available_zones.names
}