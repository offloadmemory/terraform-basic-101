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
