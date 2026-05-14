###############################################################################
# RDS - PostgreSQL
###############################################################################

# ─── DB Subnet Group ──────────────────────────────────────────────────────────
# Tells RDS which subnets it can use. Must span at least 2 AZs.

resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Private subnets for RDS"
  subnet_ids  = aws_subnet.private[*].id
  # subnet_ids = [
  #   aws_subnet.private_az1.id,
  #   aws_subnet.private_az2.id
  # ]



  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

# ─── DB Parameter Group ───────────────────────────────────────────────────────
# Lets you tune Postgres settings without recreating the instance.
# Using default values for now — easy to add custom params later.

resource "aws_db_parameter_group" "postgres" {
  name        = "${var.project_name}-postgres-params"
  family      = "postgres16"
  description = "Custom parameter group for ${var.project_name} Postgres"

  # Example of a parameter you might tune later:
  # parameter {
  #   name  = "log_min_duration_statement"
  #   value = "1000"   # Log queries slower than 1 second
  # }

  tags = {
    Name        = "${var.project_name}-postgres-params"
    Environment = var.environment
  }
}

# ─── RDS Instance ─────────────────────────────────────────────────────────────

resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  # Engine
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Storage
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 100   # Auto-scaling cap — RDS won't exceed this
  storage_type          = "gp3" # gp3 is newer/cheaper than gp2 for dev workloads
  storage_encrypted     = true  # ✅ Always encrypt at rest, even in dev

  # Credentials
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  # Networking
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false  # ✅ NEVER expose RDS directly to the internet

  # Parameters
  parameter_group_name = aws_db_parameter_group.postgres.name

  # Backups
  backup_retention_period = 7           # Keep 7 days of automatic backups
  backup_window           = "03:00-04:00" # UTC — when backups run (pick a quiet time)
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Availability
  multi_az = false  # Set to true for production! Costs ~2x but gives automatic failover.

  # Deletion protection
  # ⚠️  Set to true in production. For dev, false lets you destroy cleanly with terraform destroy.
  deletion_protection = false

  # Snapshot on destroy — safety net for dev
  # When you run `terraform destroy`, a final snapshot is created before the RDS instance is deleted. This lets you restore the database later if you accidentally destroy it.
  # Set  skip_final_snapshot = false 
  
  skip_final_snapshot       = true # Set to true to skip the final snapshot (not recommended for production)
  # final_snapshot_identifier = "${var.project_name}-${var.environment}-final-snapshot" # Only used if skip_final_snapshot is false

  # Monitoring — basic Enhanced Monitoring
  # monitoring_interval = 60  # Uncomment to enable Enhanced Monitoring (requires IAM role)

  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Environment = var.environment
  }
}



# ───────────────────────────────────────────────────────────────────
# Some best practices for RDS in production (not all implemented here since this is a dev/staging setup):
# ───────────────────────────────────────────────────────────────────
# 1. Multi-AZ deployment for high availability
# 2. Enable deletion protection to prevent accidental deletion
# 3. Use IAM authentication instead of static passwords
# 4. Store credentials securely in AWS Secrets Manager
# 5. Enable Enhanced Monitoring for better visibility into performance
# 6. Set up CloudWatch Alarms for key metrics (CPU, connections, etc.)
# 7. Regularly test your backup and restore process 
