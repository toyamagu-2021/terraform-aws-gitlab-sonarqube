variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_default_tags" {
  description = "AWS default tags"
  type        = map(string)
  default = {
    Project = "terraform-aws-gitlab-runner"
  }
}

variable "source_cidrs" {
  description = "CIDRs for public access"
  type        = list(string)
  default     = []
}

variable "gitlab" {
  description = "GitLab"
  type = object({
    instance_type = optional(string, "t3.xlarge")
  })
  default = {}
}

variable "gitlab_runner" {
  description = "GitLab Runner"
  type = object({
    instance_type = optional(string, "t3.small")
  })
  default = {}
}

variable "name_common" {
  description = "Common name"
  type        = string
  default     = "terraform-aws-gitlab-runner"
}

variable "cache_lifecycle_clear" {
  description = "Enable the rule to cleanup the cache for expired objects."
  type        = bool
  default     = true
}

variable "cache_lifecycle_prefix" {
  description = "Object key prefix identifying one or more objects to which the clean up rule applies."
  type        = string
  default     = "runner/"
}

variable "cache_expiration_days" {
  description = "Number of days before cache objects expires."
  type        = number
  default     = 1
}

variable "runner_registration_config" {
  description = "Runner config used in registration. See: https://docs.gitlab.com/ee/api/runners.html#register-a-new-runner"
  type = object({
    description      = optional(string, "")
    paused           = optional(string, "false")
    locked           = optional(string, "false")
    run_untagged     = optional(string, "true")
    tag_list         = optional(string, "")
    access_level     = optional(string, "not_protected")
    maximum_timeout  = optional(string, "3600")
    maintenance_note = optional(string, "")
  })
  default = {}
}

variable "runner_cache_s3_sse" {
  description = "S3 bucket SSE config"
  type = object({
    algorithm            = optional(string, "AES256")
    kms_master_key_alias = optional(string, null)
  })
  default = {}
}
