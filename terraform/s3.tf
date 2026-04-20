# ============================================================
# Amazon S3 — Asset Storage Bucket
# Requirements:
#   ✅ Unique bucket name (prefix + random suffix)
#   ✅ Versioning enabled
#   ✅ Server-side encryption (AES-256)
#   ✅ Public access fully blocked
# ============================================================

# Generate a random suffix for globally unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ── S3 Bucket ────────────────────────────────────────────────
resource "aws_s3_bucket" "shopsmart" {
  bucket        = "${var.s3_bucket_prefix}-${random_id.bucket_suffix.hex}"
  force_destroy = true # Allow terraform destroy to remove non-empty bucket

  tags = {
    Name        = var.s3_bucket_prefix
    Environment = "lab"
  }
}

# ── Versioning — keeps history of every object revision ──────
resource "aws_s3_bucket_versioning" "shopsmart" {
  bucket = aws_s3_bucket.shopsmart.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ── Encryption — AES-256 server-side encryption at rest ──────
resource "aws_s3_bucket_server_side_encryption_configuration" "shopsmart" {
  bucket = aws_s3_bucket.shopsmart.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ── Public Access Block — all four flags set to true ─────────
resource "aws_s3_bucket_public_access_block" "shopsmart" {
  bucket = aws_s3_bucket.shopsmart.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
