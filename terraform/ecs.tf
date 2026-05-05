# ============================================================
# Amazon ECS — Fargate Cluster, Task Definitions & Services
# Cluster is pre-existing (referenced via data source).
# Images come from Docker Hub via TF_VAR_backend_image /
# TF_VAR_frontend_image — ECR is blocked by lab policy.
# ============================================================

# ── ECS Cluster (pre-existing, do NOT create) ────────────────
data "aws_ecs_cluster" "main" {
  cluster_name = var.ecs_cluster_name
}

# ── Backend Task Definition ──────────────────────────────────
resource "aws_ecs_task_definition" "backend" {
  family                   = "shopsmart-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory

  # AWS Academy LabRole — already exists, do NOT create via IAM
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_image   # Docker Hub image, e.g. user/shopsmart-backend:abc12345
      essential = true

      portMappings = [
        {
          containerPort = var.backend_port
          protocol      = "tcp"
        }
      ]

      environment = [
        for key, value in var.backend_env_vars : {
          name  = key
          value = value
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/shopsmart-backend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])

  tags = {
    Name    = "shopsmart-backend-task"
    Service = "backend"
  }
}

# ── Frontend Task Definition ─────────────────────────────────
resource "aws_ecs_task_definition" "frontend" {
  family                   = "shopsmart-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory

  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  task_role_arn      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = var.frontend_image   # Docker Hub image, e.g. user/shopsmart-frontend:abc12345
      essential = true

      portMappings = [
        {
          containerPort = var.frontend_port
          protocol      = "tcp"
        }
      ]

      environment = [
        for key, value in var.frontend_env_vars : {
          name  = key
          value = value
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/shopsmart-frontend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])

  tags = {
    Name    = "shopsmart-frontend-task"
    Service = "frontend"
  }
}

# ── Backend ECS Service ──────────────────────────────────────
resource "aws_ecs_service" "backend" {
  name            = "shopsmart-backend-service"
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  force_new_deployment = true

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  tags = {
    Name        = "shopsmart-backend-service"
    Environment = "lab"
    Service     = "backend"
  }
}

# ── Frontend ECS Service ─────────────────────────────────────
resource "aws_ecs_service" "frontend" {
  name            = "shopsmart-frontend-service"
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  force_new_deployment = true

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  tags = {
    Name        = "shopsmart-frontend-service"
    Environment = "lab"
    Service     = "frontend"
  }
}
