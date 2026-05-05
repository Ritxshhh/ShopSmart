# ============================================================
# Outputs — Surface key resource identifiers after apply
# ECR and S3 outputs removed (blocked by AWS Academy lab policy)
# ============================================================

# ── ECS ──────────────────────────────────────────────────────
output "ecs_cluster_name" {
  description = "ECS Fargate cluster name"
  value       = data.aws_ecs_cluster.main.cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS Fargate cluster ARN"
  value       = data.aws_ecs_cluster.main.arn
}

output "backend_service_name" {
  description = "Backend ECS service name"
  value       = aws_ecs_service.backend.name
}

output "frontend_service_name" {
  description = "Frontend ECS service name"
  value       = aws_ecs_service.frontend.name
}

output "backend_image" {
  description = "Docker image deployed to the backend service"
  value       = var.backend_image
}

output "frontend_image" {
  description = "Docker image deployed to the frontend service"
  value       = var.frontend_image
}
