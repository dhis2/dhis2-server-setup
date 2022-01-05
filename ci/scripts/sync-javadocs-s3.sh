#!/usr/bin/env bash

set -euo pipefail

DOC_LOCATION="${WORKSPACE}/dhis-2/target/site/apidocs"
# the second argument is the branch (suffixed with '/'), in the case that $1 is a tag
S3_LOCATION="s3://docs.dhis2.org/javadoc/$1/"

# Copy doc directories to S3
aws s3 sync --no-progress $DOC_LOCATION $S3_LOCATION
