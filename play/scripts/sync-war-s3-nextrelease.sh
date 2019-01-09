#!/bin/bash

# This script is the same as sync-war-s3.sh, but allows a second parameter to be
# provieded in the case that the target directory is different from the version
# ID. For example, a patch build like, 2.31.1, might be sent to
# <releases>/2.31/2.31.1/ instead of <releases>/2.31.1/

WAR_LOCATION="/ebs1/jenkins/workspace/dhis2-$1/dhis-2/dhis-web/dhis-web-portal/target/dhis.war"
S3_LOCATION="s3://releases.dhis2.org/$2/dhis.war"

if [ ! -d /ebs1/jenkins/workspace/dhis2-$1 ]; then
  echo "No job with name dhis2-$1 exists."
  exit 1
fi

# Copy WAR file to S3
aws s3 cp $WAR_LOCATION $S3_LOCATION
