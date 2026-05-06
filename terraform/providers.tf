terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 backend — configured dynamically via CLI flags in deploy.yml.
  # When the TF_STATE_BUCKET secret is not set the workflow falls back
  # to local state by passing `-backend=false`.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
