# terraform-aws-gitlab-runner-autoscale

## Useful commands

- ssm
  - `aws ssm start-session --target $(terraform output --raw gitlab_instance_id)`
- SSH over ssm
  - `ssh -i ./outputs/gitlab/gitlab  -o ProxyCommand="aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'" ec2-user@$(terraform output gitlab_instance_id)`
- Fetch Admin secret of GitLab
  - `bash ./scripts/fetch_gitlab_admin_secret.sh $(terraform output --raw gitlab_instance_id)`

