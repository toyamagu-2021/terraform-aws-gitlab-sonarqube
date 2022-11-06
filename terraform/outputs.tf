output "gitlab_instance_id" {
  description = "GitLab instance id"
  value       = module.gitlab.id
}

output "gitlab_public_ip" {
  description = "GitLab instance public ip"
  value       = module.gitlab.public_ip
}

output "gitlab_public_dns" {
  description = "GitLab instance public dns"
  value       = module.gitlab.public_dns
}
