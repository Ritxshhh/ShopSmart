# ============================================================
# Amazon ECR — Container Registries
# AWS Academy: resources are pre-created manually in the console.
# Terraform imports them; it will NOT attempt to create them.
# ============================================================

# ── Backend ECR Repository ──────────────────────────────────
data "aws_ecr_repository" "backend" {
  name = var.ecr_backend_repo_name
}

# ── Frontend ECR Repository ─────────────────────────────────
data "aws_ecr_repository" "frontend" {
  name = var.ecr_frontend_repo_name
}

# ── Lifecycle Policies (keep last 5 images) ──────────────────
resource "aws_ecr_lifecycle_policy" "backend_policy" {
  repository = data.aws_ecr_repository.backend.name

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
  repository = data.aws_ecr_repository.frontend.name

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
