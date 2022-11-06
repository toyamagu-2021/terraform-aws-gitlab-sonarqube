resource "aws_security_group" "gitlab" {
  name        = local.gitlab.name
  description = "SG for GitLab"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "egress_internet_access" {
  name        = "egress-internet-access"
  description = "SG for internet access"
  vpc_id      = module.vpc.vpc_id

  egress {
    description = "Internet access https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Internet access http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "gitlab_ingress_source_cidrs_80" {
  type              = "ingress"
  description       = "From source cidrs"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = local.source_cidrs
  security_group_id = aws_security_group.gitlab.id
}

resource "aws_security_group_rule" "gitlab_ingress_source_cidrs_443" {
  type              = "ingress"
  description       = "From source cidrs"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = local.source_cidrs
  security_group_id = aws_security_group.gitlab.id
}

resource "aws_security_group_rule" "gitlab_ingress_source_cidrs_9000" {
  type              = "ingress"
  description       = "From source cidrs"
  from_port         = 9000
  to_port           = 9000
  protocol          = "tcp"
  cidr_blocks       = local.source_cidrs
  security_group_id = aws_security_group.gitlab.id
}
