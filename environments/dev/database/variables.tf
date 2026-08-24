variable "region" {
  description = "AWS region for the database"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile used for the database"
  type        = string
}

variable "db_identifier" {
  description = "Name of the RDS instance"
  type        = string
}

variable "db_name" {
  description = "Name of the database inside the RDS instance"
  type        = string
}

variable "db_username" {
  description = "Database master username (the password is generated and managed by AWS)"
  type        = string
}

variable "db_instance_class" {
  description = "Instance type of the database"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage for the database in GB"
  type        = number
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group created from the network private subnets"
  type        = string
}

variable "db_backup_retention_period" {
  description = "Number of days to keep automated backups"
  type        = number
  default     = 7
}

variable "db_skip_final_snapshot" {
  description = "Skip the final snapshot when the database is destroyed (demo-friendly)"
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "Protect the database from being deleted"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all database resources"
  type        = map(string)
  default     = {}
}
