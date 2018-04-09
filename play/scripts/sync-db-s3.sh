#!/bin/bash

DB_DIR="/ebs1/databases"

CUR_DIR=$(pwd)

# Move to db directory
cd $DB_DIR

# Pull latest updates
git pull --ff-only --all

# Sync with S3
aws s3 sync . s3://databases.dhis2.org

# Move back to original directory
cd $CUR_DIR

