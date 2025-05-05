# ============================================================
# Amazon ECR — Container Registries
# These repositories are managed by Terraform.
# ============================================================

# ── Backend ECR Repository ──────────────────────────────────
resource "aws_ecr_repository" "backend" {
  name                 = var.ecr_backend_repo_name
  image_tag_mutability = "MUTABLE"
  tags = {
    Name    = var.ecr_backend_repo_name
    Service = "backend"
  }
}

# ── Frontend ECR Repository ─────────────────────────────────
resource "aws_ecr_repository" "frontend" {
  name                 = var.ecr_frontend_repo_name
  image_tag_mutability = "MUTABLE"
  tags = {
    Name    = var.ecr_frontend_repo_name
    Service = "frontend"
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
