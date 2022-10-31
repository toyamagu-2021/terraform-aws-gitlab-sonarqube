module "vpc" {
  source                = "terraform-aws-modules/vpc/aws"
  version               = "3.14.4"
  name                  = local.vpc.name
  cidr                  = local.vpc.cidr
  secondary_cidr_blocks = local.vpc.secondary_cidr
  azs                   = local.vpc.azs
  private_subnets       = local.vpc.private_subnets
  intra_subnets         = local.vpc.intra_subnets
  public_subnets        = local.vpc.public_subnets
  enable_nat_gateway    = true
  single_nat_gateway    = true
  enable_dns_hostnames  = true
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

module "gitlab" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.4"

  name = local.gitlab.name

  iam_instance_profile = aws_iam_instance_profile.gitlab.id

  ami               = data.aws_ami.amazon_linux.id
  instance_type     = local.gitlab.instance_type
  availability_zone = element(module.vpc.azs, 0)
  subnet_id         = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids = [
    aws_security_group.gitlab.id,
    aws_security_group.egress_internet_access.id
  ]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.gitlab.key_name

  user_data_base64            = base64encode(local.gitlab.user_data)
  user_data_replace_on_change = true

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
    },
  ]
}

resource "aws_key_pair" "gitlab" {
  key_name   = local.gitlab.name
  public_key = tls_private_key.gitlab.public_key_openssh
}

resource "tls_private_key" "gitlab" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "gitlab_key_pem" {
  content         = tls_private_key.gitlab.private_key_openssh
  filename        = "${path.module}/outputs/gitlab/gitlab"
  file_permission = "600"
}

resource "local_file" "gitlab_key_pem_pub" {
  content  = tls_private_key.gitlab.public_key_openssh
  filename = "${path.module}/outputs/gitlab/gitlab.pub"
}

