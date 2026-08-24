# ── Common ──────────────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region for all resources"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile used for all resources"
  type        = string
}

# ── Network (network.tf) ─────────────────────────────────────────────────────

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "Availability zones to spread the subnets across"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets (one per AZ)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets (one per AZ)"
  type        = list(string)
}

# ── Database (database.tf) ───────────────────────────────────────────────────

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
  description = "Name of the DB subnet group created from the VPC private subnets"
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

# ── ECS (ecs.tf) ─────────────────────────────────────────────────────────────

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "alb_name" {
  description = "Name of the application load balancer"
  type        = string
}

variable "container_image" {
  description = "Docker image the ECS service runs"
  type        = string
}

variable "log_retention_days" {
  description = "How many days to keep CloudWatch container logs"
  type        = number
  default     = 7
}

# ── Tags ─────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    Project   = "terraform-basic-101"
    ManagedBy = "terraform"
  }
}
