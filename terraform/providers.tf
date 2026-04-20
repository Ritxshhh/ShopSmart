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

  # Backend block is overridden at init time via backend.override.tf generated in CI.
  # S3 remote state when TF_STATE_BUCKET is set, local state otherwise.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

# Auto-fetch current AWS Account ID — avoids hardcoding
data "aws_caller_identity" "current" {}
