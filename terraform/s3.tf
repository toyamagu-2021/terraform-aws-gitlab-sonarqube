resource "aws_s3_bucket" "runner_cache" {
  bucket        = local.s3_runner_cache.bucket
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "runner_cache" {
  bucket = aws_s3_bucket.runner_cache.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "runner_cache" {
  bucket = aws_s3_bucket.runner_cache.id

  rule {
    id     = "clear"
    status = var.cache_lifecycle_clear ? "Enabled" : "Disabled"

    filter {
      prefix = var.cache_lifecycle_prefix
    }

    expiration {
      days = var.cache_expiration_days
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "runner_cache" {
  bucket = aws_s3_bucket.runner_cache.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.runner_cache_s3_sse.algorithm
      kms_master_key_id = local.s3_runner_cache.cmk_provided ? data.aws_kms_key.runner_cache[0].arn : null
    }
  }
}

# block public access to S3 cache bucket
resource "aws_s3_bucket_public_access_block" "runner_cache" {
  bucket = aws_s3_bucket.runner_cache.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_object" "docker_compose" {
  content = templatefile("${path.module}/tftpls/docker-compose.tftpl.yaml", {
    gitlab = local.runner_config
  })
  bucket = aws_s3_bucket.runner_cache.bucket
  key    = "gitlab-bootstrap/docker/docker-compose.yaml"
}

resource "aws_s3_object" "runner_config" {
  content = templatefile("${path.module}/tftpls/config.tftpl.toml", {
    gitlab = local.runner_config
  })
  bucket = aws_s3_bucket.runner_cache.bucket
  key    = "gitlab-bootstrap/docker/data/gitlab-runner/config.toml.before_envsubst"
}

resource "aws_s3_object" "sonarqube_dockerfile" {
  source = "${path.module}/tftpls/sonarqube.dockerfile"
  bucket = aws_s3_bucket.runner_cache.bucket
  key    = "gitlab-bootstrap/docker/sonarqube.dockerfile"
}
