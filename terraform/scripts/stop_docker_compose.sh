#!/bin/bash

if [ $# -lt 1 ]; then
  echo "usage: $0 [EC2ID]"
  exit 1
fi

SCRIPT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")

CMD="cd /containers/docker && docker compose down"
bash "${SCRIPT_DIR}/run_command_by_ssm.sh" $1 "${CMD}"
