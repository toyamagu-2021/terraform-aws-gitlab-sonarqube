#!/bin/bash

if [ $# -lt 2 ]; then
  echo "usage: $0 [EC2ID] [CMD}"
  exit 1
fi

EC2_ID=$1
CMD=$2

CMD_ID=$(aws ssm send-command \
  --instance-ids ${EC2_ID} \
  --document-name  AWS-RunShellScript \
  --parameters commands="${CMD}" \
  --query "Command.CommandId" \
  --output text)

aws ssm wait command-executed --command-id ${CMD_ID} --instance-id ${EC2_ID}

aws ssm list-command-invocations \
--command-id ${CMD_ID} \
--detail \
--query "CommandInvocations[].CommandPlugins[].Output" \
--output text