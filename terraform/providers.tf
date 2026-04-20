# ============================================================
# Terraform Provider & Backend Configuration
# AWS Academy compatible — uses pre-existing LabRole
# ============================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # S3 backend for remote state (values supplied via -backend-config at init)
  # Falls back to local state in AWS Academy environments when TF_STATE_BUCKET is unset
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

# Auto-fetch current AWS Account ID — avoids hardcoding
data "aws_caller_identity" "current" {}
