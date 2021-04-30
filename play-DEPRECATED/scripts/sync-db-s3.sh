#!/bin/bash

# INIT
. env.sh

# GLOBALS
# ---
# DB_DIR

# Move to db directory
pushd $DB_DIR

# Pull latest updates
git pull --ff-only --all

# Sync with S3
aws s3 sync --exclude ".git/*" . s3://databases.dhis2.org

# Move back to original directory
popd
