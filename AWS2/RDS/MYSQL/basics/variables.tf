# variable "db_name" {
#   type        = string
#   default     = "mydatabase"
#   description = "The name of the database"
# }

variable "db_username" {
  type        = string
  default     = "princewillopah"
  description = "The master username for the RDS instance"
}

variable "db_password" {
  type        = string
  description = "The master password for the RDS instance"
  default = "PRINCEWILL@#1980"
#   sensitive   = true
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Instance type for the RDS"
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage size in GB"
}

variable "db_engine_version" {
  type        = string
  default     = "8.0"
  description = "Database engine version"
}
