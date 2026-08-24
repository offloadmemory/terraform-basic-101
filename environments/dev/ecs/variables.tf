variable "region" {
  description = "AWS region for the ECS service"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile used for the ECS service"
  type        = string
}

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

variable "tags" {
  description = "Tags applied to all ECS resources"
  type        = map(string)
  default     = {}
}
