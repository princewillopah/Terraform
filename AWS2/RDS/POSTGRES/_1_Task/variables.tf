###############################################################################
# VARIABLES
# Edit the defaults here to match your project
###############################################################################




variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Used to prefix/name all resources so you can find them easily"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment name (used in tags)"
  type        = string
  default     = "staging"
}

# ─── VPC / Networking ────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR block for the VPC. /16 gives you 65,536 IPs — plenty for dev/staging."
  type        = string
  default     = "10.0.0.0/16"
}

# ─── RDS ─────────────────────────────────────────────────────────────────────

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "dbadmin"
  # ⚠️  Never commit a production password to git.
  # For staging it's fine to use a default, but you should still
  # override this via a .tfvars file or environment variable:
  #   export TF_VAR_db_username=myuser
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
  # NO default — Terraform will prompt you for this on every apply.
  # Or set it via: export TF_VAR_db_password=supersecret
  # Next step up: store this in AWS Secrets Manager (covered in the README).
}

variable "db_instance_class" {
  description = "RDS instance size. db.t3.micro is free-tier eligible and fine for dev."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Storage in GB. 20 GB is the minimum for gp2."
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "16.3"
}

variable "db_port" {
  description = "Port Postgres listens on"
  type        = number
  default     = 5432
}

# ─── Bastion Host ─────────────────────────────────────────────────────────────

variable "bastion_instance_type" {
  description = "Bastion EC2 instance type. t3.nano is the cheapest option."
  type        = string
  default     = "t3.nano"
}

variable "bastion_key_pair_name" {
  description = <<EOT
Name of an existing EC2 Key Pair for SSH access to the Bastion.
Create one in the AWS Console → EC2 → Key Pairs, then put the name here.
EOT
  type        = string
  default     = "Princewill-ssh-bayero-sub"
}

variable "app_key_pair_name" {
  description = "Name of an existing EC2 Key Pair for SSH access to the App EC2 instance"
  type        = string
  default     = "Princewill-ssh-bayero-sub"
}
