output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.rds_instance.endpoint
}

output "rds_port" {
  description = "RDS Port"
  value       = aws_db_instance.rds_instance.port
}

output "rds_username" {
  description = "RDS Username"
  value       = aws_db_instance.rds_instance.username
}

# output "rds_db_name" {
#   description = "RDS Database Name"
#   value       = aws_db_instance.rds_instance.name
# }
