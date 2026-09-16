output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = module.web_stack.alb_dns_name
}

output "application_url" {
  description = "Public HTTPS URL of the application."
  value       = module.web_stack.application_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.web_stack.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = module.web_stack.ecs_service_name
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.network.vpc_id
}
