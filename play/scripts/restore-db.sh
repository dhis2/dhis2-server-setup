#!/bin/bash

# INIT
. env.sh

# GLOBALS
# ---
# TMP_DIR
# BASE_URL
# DB_BASE_DIR
# DB_FILE
# AUTH

# Requires that the demo database GitHub repository is cloned locally.
# Requires that a 'dhis' database user which can create databases exists.

# Sample usage: $ ./restore-db.sh dev

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  exit 1
fi

function validate() {
  if [ ! -d "${DB_BASE_DIR}/${1}" ]; then
    echo "Instance $1 does not have the required SQL file database directory."
    exit 1
  fi
}

function run() {
  echo "Restoring database: $1"
  
  sudo -u postgres dropdb "$1"
  sudo -u postgres createdb -O dhis "$1"
  echo "Dropped and created db: $1"

  cp "${DB_BASE_DIR}/${1}/${DB_FILE}.sql.gz" "${TMP_DIR}/${DB_FILE}-${1}.sql.gz"
  gunzip -f "${TMP_DIR}/${DB_FILE}-${1}.sql.gz"
  psql -d "$1" -U dhis -f "${TMP_DIR}/${DB_FILE}-${1}.sql"
  echo "Restored database: $1"
}

for instance in $@; do
  validate $instance
  run $instance
done
