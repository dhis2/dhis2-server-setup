#!/bin/bash

# Requires that the demo database GitHub repository is cloned locally.
# Requires that a 'dhis' database user which can create databases exists.
# The 'TMP_DIR' and 'DB_BASE_DIR' variables can be adjusted to match the local env.
# Sample usage: $ ./restore-db.sh dev

TMP_DIR="/ebs1/tmp"
DB_BASE_DIR="/ebs1/databases/sierra-leone"
DB_FILE="dhis2-db-sierra-leone"
AUTH="system:System123"

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  exit 1
fi

function validate() {
  if [ ! -d $DB_BASE_DIR/$1 ]; then
    echo "Instance $1 does not have the required SQL file database directory."
    exit 1
  fi
}

function run() {
  echo "Restoring database: $1"
  
  sudo -u postgres dropdb $1
  sudo -u postgres createdb -O dhis $1
  echo "Dropped and created db: $1"

  cp $DB_BASE_DIR/$1/$DB_FILE.sql.gz ${TMP_DIR}/$DB_FILE-$1.sql.gz
  gunzip -f ${TMP_DIR}/$DB_FILE-$1.sql.gz
  psql -d $1 -U dhis -f ${TMP_DIR}/$DB_FILE-$1.sql
  echo "Restored database: $1"
}

for instance in $@; do
  validate $instance
  run $instance
done
