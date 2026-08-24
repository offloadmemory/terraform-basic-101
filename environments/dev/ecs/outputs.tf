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
