# ---------------------------------------------------------------------------
# Amazon ECR — container image repositories
# ---------------------------------------------------------------------------

resource "aws_ecr_repository" "backend" {
  name                 = "shopsmart-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "shopsmart-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
