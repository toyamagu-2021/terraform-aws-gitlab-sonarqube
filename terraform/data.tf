data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "ubuntu_20" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_kms_key" "runner_cache" {
  count  = local.s3_runner_cache.cmk_provided ? 1 : 0
  key_id = var.runner_cache_s3_sse.kms_master_key_alias
}

