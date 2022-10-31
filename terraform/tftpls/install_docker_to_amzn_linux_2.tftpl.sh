#!/bin/bash

# For sonarqube
## Error Reference: bootstrap check failure [1] of [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
sysctl -q -w vm.max_map_count=262144

## Install docker
sudo yum update -y
sudo yum install jq -y
sudo amazon-linux-extras install docker -y
sudo groupadd docker
sudo usermod -aG docker ec2-user
newgrp docker
sudo systemctl enable docker
sudo systemctl start docker
docker version

## Install docker compose
mkdir -p /usr/libexec/docker/cli-plugins/
curl https://api.github.com/repos/docker/compose/releases/latest \
| grep  browser_download_url | grep linux-x86_64 | grep -v sha256 \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -qi -
sudo mv docker-compose-linux-x86_64 /usr/libexec/docker/cli-plugins/docker-compose
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
docker compose version

# Setup GitLab and GitLab Runner
## Fetch file and start GitLab
mkdir /containers && cd /containers
aws s3 sync s3://${s3_bucket.name}/${s3_bucket.key} ./docker
cd docker 
mkdir -p data/gitlab && mkdir -p data/gitlab-runner
docker compose up -d --wait gitlab sonarqube

## Fetch Runner registration token
RUNNER_REGISTRATION_TOKEN=$(docker compose exec gitlab gitlab-rails runner -e production "puts Gitlab::CurrentSettings.current_application_settings.runners_registration_token")

## Fetch Runner Authentication Token
RUNNER_AUTHENTICATION_TOKEN=$(curl --request POST "http://localhost/api/v4/runners" \
  --form "token=$${RUNNER_REGISTRATION_TOKEN}" \
  --form "description=${runner_registration_config.description}" \
  --form "paused=${runner_registration_config.paused}" \
  --form "locked=${runner_registration_config.locked}" \
  --form "run_untagged=${runner_registration_config.run_untagged}" \
  --form "tag_list=${runner_registration_config.tag_list}" \
  --form "access_level=${runner_registration_config.access_level}" \
  --form "maximum_timeout=${runner_registration_config.maximum_timeout}" \
  --form "maintenance_note=${runner_registration_config.maintenance_note}" \
  | jq .token)

## Insert RUNNER_TOKEN into config.toml of GitLab Runner
RUNNER_TOKEN=$${RUNNER_AUTHENTICATION_TOKEN} envsubst \
  < data/gitlab-runner/config.toml.before_envsubst > data/gitlab-runner/config.toml
docker compose up -d --wait gitlab-runner

