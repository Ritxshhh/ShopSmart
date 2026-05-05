# ============================================================
# Terraform Provider & Backend Configuration
# AWS Academy compatible — uses pre-existing LabRole
# S3 backend removed: s3:CreateBucket is blocked by lab policy.
# State is kept locally; re-initialise with: terraform init
# ============================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local backend — no S3 bucket needed
  backend "local" {}
}

provider "aws" {
  region = var.aws_region
}

# Auto-fetch current AWS Account ID — avoids hardcoding
data "aws_caller_identity" "current" {}
