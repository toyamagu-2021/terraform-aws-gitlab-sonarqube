// naming
locals {
  name_common = var.name_common
}

// EKS
locals {
  aws = {
    region       = var.aws_region
    default_tags = var.aws_default_tags
  }
}

//VPC
locals {
  vpc = {
    name            = local.name_common
    cidr            = "10.0.0.0/16"
    secondary_cidr  = ["100.64.0.0/16"]
    azs             = ["${local.aws.region}a", "${local.aws.region}c", "${local.aws.region}d"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    intra_subnets   = ["100.64.1.0/24", "100.64.2.0/24", "100.64.3.0/24"]
    public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  }
}

// Public access cidrs
locals {
  source_cidrs = concat(["${chomp(data.http.myip.response_body)}/32"], var.source_cidrs)
}

// GitLab 
locals {
  gitlab_user_data = templatefile("${path.module}/tftpls/install_docker_to_amzn_linux_2.tftpl.sh", {
    s3_bucket = {
      name = aws_s3_bucket.runner_cache.bucket,
      key  = "gitlab-bootstrap/docker"
    },
    runner_registration_config = var.runner_registration_config
  })
  s3_runner_cache = {
    cmk_provided = var.runner_cache_s3_sse.algorithm == "aws:kms" && var.runner_cache_s3_sse.kms_master_key_alias != "aws/s3" ? true : false
    bucket       = "${local.name_common}-${random_string.suffix.result}"
  }
  gitlab = {
    name          = "${local.name_common}-gilab"
    instance_type = var.gitlab.instance_type
    user_data     = local.gitlab_user_data
    runner = {
      name = "${local.name_common}-gilab-runner"
      machine = {
        name = "${local.name_common}-gitlab-runner-docker-machine"
      }
    }
  }
}

// GitLab Runner config
locals {
  runner_config = {
    url = "http://${module.gitlab.public_dns}:80"
    runner = {
      s3 = {
        bucket_name     = aws_s3_bucket.runner_cache.bucket
        bucket_location = aws_s3_bucket.runner_cache.region
      }
    }
  }
}
