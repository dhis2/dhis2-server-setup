#!/bin/bash

# INIT
. env.sh

# GLOBALS
# ---
# WAR_LOCATION
# S3_LOCATION
# JENKINS_WORKSPACE

if [ ! -d "${JENKINS_WORKSPACE}/dhis2-$1 ]; then
  echo "No job with name dhis2-$1 exists."
  exit 1
fi

# Copy WAR file to S3
aws s3 cp $WAR_LOCATION $S3_LOCATION
