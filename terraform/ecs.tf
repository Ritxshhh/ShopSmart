# ============================================================
# Amazon ECS — Fargate Cluster, Task Definitions & Services
# AWS Academy compatible: references pre-existing LabRole (no IAM creation)
# ============================================================

# ── ECS Cluster ──────────────────────────────────────────────
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled" # Disabled for AWS Academy cost constraints
  }

  tags = {
    Name        = var.ecs_cluster_name
    Environment = "lab"
  }
}

# ── Backend Task Definition ──────────────────────────────────
# Uses Fargate launch type with awsvpc networking.
# Image URI is built from the ECR repo URL + git SHA tag.
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
      image     = "${aws_ecr_repository.backend.repository_url}:${var.image_tag}"
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

      # CloudWatch Logs — auto-creates the log group
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
      image     = "${aws_ecr_repository.frontend.repository_url}:${var.image_tag}"
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
# force_new_deployment ensures every apply picks up the latest image
resource "aws_ecs_service" "backend" {
  name            = "shopsmart-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  force_new_deployment = true

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true # Required for Fargate tasks in public subnets
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
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.service_desired_count
  launch_type     = "FARGATE"

  force_new_deployment = true

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  tags = {
    Name        = "shopsmart-frontend-service"
    Environment = "lab"
    Service     = "frontend"
  }
}
