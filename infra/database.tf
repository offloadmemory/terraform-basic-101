# Database resources — a PostgreSQL RDS instance from the official
# Terraform Registry module terraform-aws-modules/rds/aws.
#
# Notice what is NOT here: no hand-written module, no separate state file, no
# terraform_remote_state. Because everything lives in ONE Terraform
# configuration, the database references the VPC resources directly
# (module.vpc.*) and Terraform figures out the dependency order for us.
# The RDS module creates the DB subnet group and security group for us.

# A small security group that only allows the app (ECS) to reach the DB.
module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0.0"

  name        = "basic-101-db-sg"
  description = "Security group for the basic-101 database"
  vpc_id      = module.vpc.vpc_id

  # Allow traffic from anywhere INSIDE the VPC (the app talks to the DB
  # over the private subnets, which are inside the VPC CIDR).
  ingress_rules = {
    postgres_inbound = {
      description = "PostgreSQL from inside the VPC"
      from_port   = 5432
      to_port     = 5432
      ip_protocol = "tcp"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  egress_rules = {
    all_outbound = {
      description = "Allow all outbound traffic"
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.2.1"

  identifier = var.db_identifier

  engine               = "postgres"
  engine_version       = "16.4"
  family               = "postgres16" # DB parameter group family
  major_engine_version = "16"

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  db_name  = var.db_name
  username = var.db_username

  # AWS generates and manages the master password. No password ever
  # appears in the code or in state.
  manage_master_user_password = true

  port = 5432

  vpc_security_group_ids = [module.db_sg.id]

  # Create a DB subnet group from the VPC's private subnets.
  create_db_subnet_group = true
  db_subnet_group_name   = var.db_subnet_group_name
  subnet_ids             = module.vpc.private_subnets

  backup_retention_period = var.db_backup_retention_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  tags = var.tags
}
