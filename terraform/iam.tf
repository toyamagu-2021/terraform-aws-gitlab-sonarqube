data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "gitlab" {
  name               = local.gitlab.name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_role_policy_attachment" "gitlab_runner" {
  role       = aws_iam_role.gitlab.name
  policy_arn = aws_iam_policy.runner.arn
}

resource "aws_iam_role_policy_attachment" "gitlab_ssm" {
  role       = aws_iam_role.gitlab.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "gitlab" {
  name = local.gitlab.name
  role = aws_iam_role.gitlab.name
}

resource "aws_iam_policy" "runner" {
  name   = local.gitlab.runner.name
  path   = "/"
  policy = data.aws_iam_policy_document.runner.json
}

data "aws_iam_policy_document" "runner" {
  statement {
    # Ref: https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscaches3-section
    sid       = "allowGitLabRunnersAccessCache"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.runner_cache.arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject"
    ]
  }

  dynamic "statement" {
    for_each = local.s3_runner_cache.cmk_provided ? { "name" = "kms" } : {}
    content {
      # Ref: https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runnerscaches3-section
      sid    = "allowGitLabRunnersAccessCacheKms"
      effect = "Allow"
      resources = [
        data.aws_kms_key.runner_cache[0].arn
      ]

      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
    }
  }

  # Needed only for GitLab bootstrap ( `aws s3 sync` ) 
  statement {
    sid       = "allowGitLabRunnersAccessCacheListBucket"
    effect    = "Allow"
    resources = [aws_s3_bucket.runner_cache.arn]

    actions = [
      "s3:ListBucket",
    ]
  }
}
