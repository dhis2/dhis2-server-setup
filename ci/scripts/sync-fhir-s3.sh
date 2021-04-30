#!/bin/bash

WAR_LOCATION="/ebs1/home/jenkins/workspace/dhis2-fhir-adapter/app/target/dhis2-fhir-adapter.war"
# the second argument is the branch (suffixed with '\'), in the case that $1 is a tag
S3_LOCATION="s3://releases.dhis2.org/fhir/dhis2-fhir-adapter.war"

if [ ! -d /ebs1/home/jenkins/workspace/dhis2-fhir-adapter ]; then
  echo "No job with name dhis2-fhir-adapterexists."
  exit 1
fi

# Copy WAR file to S3
~/.local/bin/aws s3 cp $WAR_LOCATION $S3_LOCATION
