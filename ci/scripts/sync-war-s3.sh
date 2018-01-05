#!/bin/bash

WAR_LOCATION=/ebs1/jenkins/workspace/dhis2-$1/dhis-2/dhis-web/dhis-web-portal/target/dhis.war
S3_LOCATION=s3://releases.dhis2.org/$1/dhis.war

if [ ! -d /ebs1/jenkins/workspace/dhis2-$1 ]; then
  echo "No job with name dhis2-$1 exists."
  exit 1
fi

# Copy WAR file to S3
aws s3 cp $WAR_LOCATION $S3_LOCATION
