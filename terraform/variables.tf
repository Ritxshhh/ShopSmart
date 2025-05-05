# ============================================================
# Input Variables for ShopSmart Infrastructure
# All environment-specific values are defined here.
# Secrets and dynamic values are injected via TF_VAR_* env vars.
# ============================================================

# ── AWS Region ──────────────────────────────────────────────
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region where all resources will be provisioned"
}

# ── ECR Repositories ───────────────────────────────────────
variable "ecr_backend_repo_name" {
  type        = string
  default     = "shopsmart-backend"
  description = "Name of the ECR repository for the backend Docker image"
}

variable "ecr_frontend_repo_name" {
  type        = string
  default     = "shopsmart-frontend"
  description = "Name of the ECR repository for the frontend Docker image"
}

# ── ECS Cluster & Services ─────────────────────────────────
variable "ecs_cluster_name" {
  type        = string
  default     = "shopsmart-cluster"
  description = "Name of the ECS Fargate cluster"
}

variable "service_desired_count" {
  type        = number
  default     = 1
  description = "Desired number of running tasks per ECS service"
}

# ── Container Resources ────────────────────────────────────
variable "backend_cpu" {
  type        = number
  default     = 256
  description = "CPU units for the backend container (1024 = 1 vCPU)"
}

variable "backend_memory" {
  type        = number
  default     = 512
  description = "Memory (MiB) for the backend container"
}

variable "frontend_cpu" {
  type        = number
  default     = 256
  description = "CPU units for the frontend container (1024 = 1 vCPU)"
}

variable "frontend_memory" {
  type        = number
  default     = 512
  description = "Memory (MiB) for the frontend container"
}

# ── Container Ports ─────────────────────────────────────────
variable "backend_port" {
  type        = number
  default     = 5001
  description = "Port exposed by the backend container"
}

variable "frontend_port" {
  type        = number
  default     = 8080
  description = "Port exposed by the frontend container (nginx on 8080)"
}

# ── Docker Image Tag ───────────────────────────────────────
variable "image_tag" {
  type        = string
  description = "Docker image tag (typically the Git SHA) — required at plan time"
}

# ── Networking ──────────────────────────────────────────────
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ECS Fargate tasks"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID attached to ECS Fargate tasks"
}

# ── Environment Variables ──────────────────────────────────
variable "backend_env_vars" {
  type        = map(string)
  default     = {}
  description = "Key-value environment variables injected into the backend container"
}

variable "frontend_env_vars" {
  type        = map(string)
  default     = {}
  description = "Key-value environment variables injected into the frontend container"
}

# ── S3 Bucket ──────────────────────────────────────────────
variable "s3_bucket_prefix" {
  type        = string
  default     = "bucketaws12341234"
  description = "Name of the S3 bucket created by Terraform"
}
