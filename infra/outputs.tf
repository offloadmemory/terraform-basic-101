# ── Network ──────────────────────────────────────────────────────────────────

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# ── Database ─────────────────────────────────────────────────────────────────

output "db_endpoint" {
  description = "Connection endpoint of the database (host:port)"
  value       = module.db.db_instance_endpoint
  sensitive   = true
}

output "db_name" {
  description = "Name of the database"
  value       = module.db.db_instance_name
}

output "db_port" {
  description = "Port the database listens on"
  value       = module.db.db_instance_port
  sensitive   = true
}

# ── ECS ──────────────────────────────────────────────────────────────────────

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_service.name
}

output "alb_dns_name" {
  description = "DNS name of the load balancer — open this URL in a browser"
  value       = module.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = module.alb.arn
}
