# ============================================================
# Amazon ECR — Container Registries
# Stores Docker images for backend and frontend services.
# Lifecycle policies keep only the last 5 images to control costs.
# ============================================================

# ── Backend ECR Repository ──────────────────────────────────
resource "aws_ecr_repository" "backend" {
  name         = var.ecr_backend_repo_name
  force_delete = true # Allows terraform destroy even with images present

  image_scanning_configuration {
    scan_on_push = true # Scan every pushed image for vulnerabilities
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = var.ecr_backend_repo_name
    Environment = "lab"
    Service     = "backend"
  }
}

# ── Frontend ECR Repository ─────────────────────────────────
resource "aws_ecr_repository" "frontend" {
  name         = var.ecr_frontend_repo_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Name        = var.ecr_frontend_repo_name
    Environment = "lab"
    Service     = "frontend"
  }
}

# ── Lifecycle Policies (keep last 5 images) ──────────────────
resource "aws_ecr_lifecycle_policy" "backend_policy" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the last 5 images to save storage"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = { type = "expire" }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "frontend_policy" {
  repository = aws_ecr_repository.frontend.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the last 5 images to save storage"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = { type = "expire" }
    }]
  })
}
