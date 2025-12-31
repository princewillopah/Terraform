# --------------------------------------------------------------------------------------------------------------------------------------------------
# Outputs (Connection Information)
# --------------------------------------------------------------------------------------------------------------------------------------------------

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
description = "RDS MySQL endpoint for connection"
}

output "rds_address" {
  value = aws_db_instance.mysql.address
}

output "rds_port" {
  value = aws_db_instance.mysql.port
description = "RDS MySQL port"
}

output "rds_database_name" {
  value = aws_db_instance.mysql.db_name
}

output "rds_username" {
  value = aws_db_instance.mysql.username
 description = "RDS master username"
}


output "rds_security_group_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}

output "connection_string_username_password" {
  description = "Complete MySQL connection string (username/password)"
  value       = "mysql://admin1:PRINCEWILLOPAH12345@${aws_db_instance.mysql.endpoint}/DB1"
}

output "connection_string_psql" {
  description = "MySQL connection string for psql/mysql CLI"
  value       = "mysql -h ${aws_db_instance.mysql.endpoint} -P 3306 -u admin1 -pPRINCEWILLOPAH12345 DB1"
}

output "jumpbox_connection_string" {
  value = "ssh -i ~/DevOps/ssh-key/${var.key_name} ubuntu@${aws_instance.jumpbox.public_ip}"
}