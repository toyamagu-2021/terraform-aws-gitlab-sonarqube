# terraform-aws-gitlab-runner-autoscale

## Useful commands

- ssm
  - `aws ssm start-session --target $(terraform output --raw gitlab_instance_id)`
- SSH over ssm
  - `ssh -i ./outputs/gitlab/gitlab  -o ProxyCommand="aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'" ec2-user@$(terraform output gitlab_instance_id)`
- Fetch Admin secret of GitLab
  - `bash ./scripts/fetch_gitlab_admin_secret.sh $(terraform output --raw gitlab_instance_id)`


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.37.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.1.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gitlab"></a> [gitlab](#module\_gitlab) | terraform-aws-modules/ec2-instance/aws | 4.1.4 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.14.4 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.gitlab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.gitlab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.gitlab_runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.gitlab_ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_key_pair.gitlab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_s3_bucket.runner_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.runner_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.runner_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_public_access_block.runner_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.runner_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_object.docker_compose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.runner_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.sonarqube_dockerfile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.egress_internet_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.gitlab](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.gitlab_ingress_source_cidrs_443](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.gitlab_ingress_source_cidrs_80](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.gitlab_ingress_source_cidrs_9000](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [local_file.gitlab_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.gitlab_key_pem_pub](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.gitlab](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy.AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.assume_role_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.runner](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.runner_cache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_default_tags"></a> [aws\_default\_tags](#input\_aws\_default\_tags) | AWS default tags | `map(string)` | <pre>{<br>  "Project": "terraform-aws-gitlab-runner"<br>}</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"ap-northeast-1"` | no |
| <a name="input_cache_expiration_days"></a> [cache\_expiration\_days](#input\_cache\_expiration\_days) | Number of days before cache objects expires. | `number` | `1` | no |
| <a name="input_cache_lifecycle_clear"></a> [cache\_lifecycle\_clear](#input\_cache\_lifecycle\_clear) | Enable the rule to cleanup the cache for expired objects. | `bool` | `true` | no |
| <a name="input_cache_lifecycle_prefix"></a> [cache\_lifecycle\_prefix](#input\_cache\_lifecycle\_prefix) | Object key prefix identifying one or more objects to which the clean up rule applies. | `string` | `"runner/"` | no |
| <a name="input_gitlab"></a> [gitlab](#input\_gitlab) | GitLab | <pre>object({<br>    instance_type = optional(string, "t3.xlarge")<br>  })</pre> | `{}` | no |
| <a name="input_name_common"></a> [name\_common](#input\_name\_common) | Common name | `string` | `"terraform-aws-gitlab-runner"` | no |
| <a name="input_runner_cache_s3_sse"></a> [runner\_cache\_s3\_sse](#input\_runner\_cache\_s3\_sse) | S3 bucket SSE config | <pre>object({<br>    algorithm            = optional(string, "AES256")<br>    kms_master_key_alias = optional(string, null)<br>  })</pre> | `{}` | no |
| <a name="input_runner_registration_config"></a> [runner\_registration\_config](#input\_runner\_registration\_config) | Runner config used in registration. See: https://docs.gitlab.com/ee/api/runners.html#register-a-new-runner | <pre>object({<br>    description      = optional(string, "")<br>    paused           = optional(string, "false")<br>    locked           = optional(string, "false")<br>    run_untagged     = optional(string, "true")<br>    tag_list         = optional(string, "")<br>    access_level     = optional(string, "not_protected")<br>    maximum_timeout  = optional(string, "3600")<br>    maintenance_note = optional(string, "")<br>  })</pre> | `{}` | no |
| <a name="input_source_cidrs"></a> [source\_cidrs](#input\_source\_cidrs) | CIDRs for public access | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gitlab_instance_id"></a> [gitlab\_instance\_id](#output\_gitlab\_instance\_id) | GitLab instance id |
| <a name="output_gitlab_public_dns"></a> [gitlab\_public\_dns](#output\_gitlab\_public\_dns) | GitLab instance public dns |
| <a name="output_gitlab_public_ip"></a> [gitlab\_public\_ip](#output\_gitlab\_public\_ip) | GitLab instance public ip |
<!-- END_TF_DOCS -->