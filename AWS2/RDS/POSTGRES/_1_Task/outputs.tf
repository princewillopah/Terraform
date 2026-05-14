###############################################################################
# OUTPUTS
# These values are printed after `terraform apply` completes.
# Use them to connect to your database.
###############################################################################

output "rds_endpoint" {
  description = "RDS hostname (use this as your DB host)"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.postgres.port
}

output "rds_db_name" {
  description = "Database name"
  value       = aws_db_instance.postgres.db_name
}

output "rds_username" {
  description = "Database master username"
  value       = aws_db_instance.postgres.username
}

output "bastion_public_ip" {
  description = "Bastion Host public IP — SSH into this first"
  value       = aws_instance.bastion.public_ip
}

output "app_private_ip" {
  description = "App EC2 private IP — SSH to this via the Bastion"
  value       = aws_instance.app.private_ip
}

output "ssh_tunnel_command" {
  description = "Run this on your local machine to create an SSH tunnel to RDS via the Bastion"
  value       = <<EOT

# ── How to connect from your LOCAL machine ──────────────────────────────────
#
# Step 1: Open an SSH tunnel (run in a separate terminal, keep it open)
ssh -N -L 5433:${aws_db_instance.postgres.endpoint}:5432 \
    -i /path/to/your/bastion-key.pem \
    ubuntu@${aws_instance.bastion.public_ip}
#
# Step 2: In another terminal, connect to Postgres via the tunnel
psql -h localhost -p 5433 -U ${aws_db_instance.postgres.username} -d ${aws_db_instance.postgres.db_name}
#
# Or use a GUI tool (pgAdmin / TablePlus / DBeaver):
#   Host:     localhost
#   Port:     5433
#   Database: ${aws_db_instance.postgres.db_name}
#   User:     ${aws_db_instance.postgres.username}
# ─────────────────────────────────────────────────────────────────────────────
EOT
}

output "app_connection_string" {
  description = "Connection string for your App EC2 (set as an env variable)"
  value       = "postgresql://${aws_db_instance.postgres.username}:<PASSWORD>@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
}
