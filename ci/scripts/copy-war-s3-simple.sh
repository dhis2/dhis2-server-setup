#!/usr/bin/env bash

set -euo pipefail

S3_CMD="aws s3 cp --metadata git-commit=$GIT_COMMIT --no-progress"

DESTINATION="$1"

if [[ -z "$1" ]]; then
  echo "Error: S3 Destination is required."
  exit 1
fi

WAR_LOCATION="${WORKSPACE}/dhis-2/dhis-web/dhis-web-portal/target/dhis.war"

if [[ ! -f "$WAR_LOCATION" ]]; then
  echo "Error: WAR file not found."
  exit 1
fi

$S3_CMD "$WAR_LOCATION" "$DESTINATION"
