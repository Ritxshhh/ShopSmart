# ============================================================
# Amazon S3 — Asset Storage Bucket
# AWS Academy: bucket is pre-created manually in the console.
# Terraform reads it via data source and manages its configuration.
# ============================================================

# ── S3 Bucket (pre-existing, read-only) ──────────────────────
data "aws_s3_bucket" "shopsmart" {
  bucket = var.s3_bucket_prefix
}

# ── Versioning — keeps history of every object revision ──────
resource "aws_s3_bucket_versioning" "shopsmart" {
  bucket = data.aws_s3_bucket.shopsmart.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ── Encryption — AES-256 server-side encryption at rest ──────
resource "aws_s3_bucket_server_side_encryption_configuration" "shopsmart" {
  bucket = data.aws_s3_bucket.shopsmart.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ── Public Access Block — all four flags set to true ─────────
resource "aws_s3_bucket_public_access_block" "shopsmart" {
  bucket = data.aws_s3_bucket.shopsmart.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
