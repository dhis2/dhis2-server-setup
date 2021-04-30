#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $0 <instance> <awx-credentials>"
  exit 1
fi

json="{\"extra_vars\":{\"instance_name\": \"${1}\" ,\"instance_action\": \"reset_war\"}}"

curl -u $2 -X "POST" -H "Content-Type: application/json" -d "${json}" https://awx.dhis2.org/api/v2/job_templates/60/launch/
