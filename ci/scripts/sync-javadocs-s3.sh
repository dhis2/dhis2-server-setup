#!/usr/bin/env bash

set -euo pipefail

DOC_LOCATION="${JENKINS_HOME}/jobs/${JOB_NAME}/branches/$1/javadoc/."
# the second argument is the branch (suffixed with '/'), in the case that $1 is a tag
S3_LOCATION="s3://test-docs.dhis2.org/javadoc/$1/"

# Copy doc directories to S3
aws s3 sync $DOC_LOCATION $S3_LOCATION
