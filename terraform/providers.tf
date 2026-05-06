terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configured dynamically:
  # - S3 backend via -backend-config flags when TF_STATE_BUCKET is set
  # - Local backend (default) when TF_STATE_BUCKET is not set
}

provider "aws" {
  region = var.aws_region
}
