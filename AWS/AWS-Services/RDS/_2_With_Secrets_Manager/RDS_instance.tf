
## --------------------------------------------------------------------------------------------------------------------------------------------------
#@ RDS MySQL Instance (FULLY EXPLICIT)
#@ --------------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "mysql" {

  #################################
  # BASIC IDENTIFICATION
  #################################

  identifier = "mysql-prod-db" # default = none (required) - # Unique name for the DB instance

  #################################
  # ENGINE CONFIGURATION
  #################################

  engine               = "mysql"        # required
  engine_version       = "8.0.43"       # default = latest supported  # # Use latest minor version; check AWS for availability
  instance_class       = "db.m5d.large"  # default = none (required) - # Default dev class; prod: db.m6g.large, etc.

  #################################
  # # SECRETS MANAGER INTEGRATION 
  #################################
  
  manage_master_user_password = true
  # master_user_secret_kms_key_id = aws_kms_key.secrets.arn  # optional


  #################################
  # DATABASE CONFIG
  #################################

  db_name              = "DB1"                                     # default = null   # Initial database name (must start with letter)
  username             = var.username                               # required
  # password             = var.password                               # required
  port                 = 3306                                        # default = engine default (3306)

  #################################
  # STORAGE
  #################################

  allocated_storage     = 100            # default = 20 GB // # Initial storage in GB
  max_allocated_storage = 1000           # default = null (autoscaling off) but Auto-scale up to 1TB (0 = disabled, default)
  storage_type          = "gp3"           # default = gp2 //  # gp3 is latest high-performance (default: gp2)
  storage_encrypted     = true            # default = false //  # PRODUCTION: Always enable encryption
  kms_key_id            = null            # default = AWS managed key
#   iops                   = 3000            # Provisioned IOPS for gp3 (default: 3000) - set    iops  = 0 if storage_type  = "gp3".   iops  is Only for io1/gp3; gp2 auto-scales IOPS
  # storage_throughput    = 0 # gp3 only; default = 125 MB/s if not set

#################################
  # HIGH AVAILABILITY
  #################################

  multi_az = true  # default = false - for prod, set it to true

  #################################
  # NETWORKING
  #################################

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    =  false        # default = false  -  # Set false for production private subnets

  #################################
  # BACKUPS
  #################################

  backup_retention_period = 7                    # # Days to retain backups (default: 7, max 35)(0 disables backups)
  backup_window           = "03:00-04:00" # # UTC window (default: random) - default = random  
  copy_tags_to_snapshot  = true           #  # Copy tags to snapshots (default: false)
  delete_automated_backups = true    # default = true  # Keep automated backups (default: false)

  #################################
  # MAINTENANCE
  #################################

  maintenance_window = "sun:05:00-sun:06:00" # default = random# UTC window (default: random)
  auto_minor_version_upgrade = true # # Auto minor upgrades (default: true)
  allow_major_version_upgrade = false # default = false
  apply_immediately = false # # Changes during maintenance window (default: false)

  #################################
  # MONITORING & Performance
  #################################

  monitoring_interval = 60  # CloudWatch enhanced monitoring (0=disabled, default: 0)# default = 0 (disabled) 
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn  # Required if monitoring_interval > 0 # default = null 

  performance_insights_enabled = true  # Performance Insights # default = false // only for large instance db.m5d.large and above and where multi_az = true or multi_az = true and instance class is db.t3.small and above
  performance_insights_retention_period = 7 # default = 7   7 # Only if enabled; options: 7 or 731
  # performance_insights_kms_key_id = null # default = AWS managed / value can be "" # Optional KMS key

  #################################
  # LOGGING
  #################################

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery" ] # Export logs to CloudWatch # default = []  - # Default: none

  #################################
  # DELETION & PROTECTION
  #################################

  deletion_protection = false #  #Prevent accidental deletion -  Default = false; set true in prod
  skip_final_snapshot = false #  # Always create final snapshot - Default = false; but set true in dev
  final_snapshot_identifier = "mysql-final-snapshot"  #  # Template with timestamp - Required if skip_final_snapshot = false
 




  #################################
  # Timeouts 
  #################################

  timeouts {
    create = "90m"
    delete = "60m"
    update = "80m"
  }

  #################################
  # == REPLICATION (Single instance) ==
  #################################


  replicate_source_db    = null  # Not a replica (default)
  replica_mode           = null  # Not applicable (default)


  #################################
  # == === ADVANCED =====
  #################################

  license_model          = "general-public-license"                                            # MySQL default
#   timezone               = "UTC"    //  only when you add parameter                                                                               # Set timezone (default: none)
  domain                 = null                                                                                        # Active Directory domain (default)
  domain_iam_role_name   = null                                                                       # Domain IAM role (default)
  domain_fqdn            = null                                                                                   # Domain FQDN (default)
  domain_ou              = null                                                                                     # Domain OU (default)
  domain_auth_secret_arn = null                                                                         # Domain auth secret (default)
  # enabled_cloudwatch_logs_exports = ["slowquery", "general", "error"]  # Duplicate for compatibility
  storage_throughput     = null                                                                               # gp3 default (500 MB/s)
#   manage_master_user_password = false                                                          # Manual password management (default: false)


  #################################
  # TAGGING
  #################################

  tags = {
    Name        = "mysql-production"
    Environment = "production"
  }
} // end aws_db_instance
