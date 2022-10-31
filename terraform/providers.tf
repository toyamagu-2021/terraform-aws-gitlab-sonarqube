provider "aws" {
  region = local.aws.region
  default_tags {
    tags = local.aws.default_tags
  }
}
