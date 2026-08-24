output "state_bucket_name" {
  description = "Name of the state bucket"
  value       = module.state_bucket.s3_bucket_id
}

output "state_bucket_arn" {
  description = "ARN of the state bucket"
  value       = module.state_bucket.s3_bucket_arn
}
