output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer."
  value       = aws_lb.app.dns_name
}

output "application_url" {
  description = "HTTP/S URL of the Application Load Balancer."
  value       = local.https_enabled ? "https://${var.https.domain_name}" : "http://${aws_lb.app.dns_name}"
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.app.name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.app.name
}
