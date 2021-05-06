#!/bin/bash

DOC_LOCATION="/ebs1/home/jenkins/jobs/${JOB_NAME}/javadoc/."
# the second argument is the branch (suffixed with '/'), in the case that $1 is a tag
S3_LOCATION="s3://docs.dhis2.org/javadoc/$1/"

# Copy doc directories to S3
~/.local/bin/aws s3 sync $DOC_LOCATION $S3_LOCATION

