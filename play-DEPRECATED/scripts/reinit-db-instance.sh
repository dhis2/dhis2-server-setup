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
DBVERSION="DHIS2_DB_VERSION"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  echo -e "Availalable instances:"
  ls -1 ${BASE_DIR}
  exit 1
fi

function getVersion() {
  # By default the dhis2 db version is the same as the instance name
  # but that can be overridden with the contents of the DHIS2_DB_VERSION file
  DHIS2_VERSION=$1
  if [ -e ${BASE_DIR}/$1/$DBVERSION ]; then
    DHIS2_VERSION=`cat ${BASE_DIR}/$1/$DBVERSION`
  fi
  set -- "$DHIS2_VERSION"
}

function validate() {

  if [ ! -d "${BASE_DIR}/${1}" ]; then
    echo "Instance $1 does not exist."
    exit 1
  fi
  DHIS2_VERSION=$1
  getVersion $DHIS2_VERSION
  if [ ! -d "${DB_BASE_DIR}/${DHIS2_VERSION}" ]; then
    echo "Instance $1 does not have the required SQL file database directory $DB_BASE_DIR/$DHIS2_VERSION."
    exit 1
  fi
}

function run() {
  $DIR/stop-instance.sh $1
  sleep 5
  sudo -u postgres dropdb $1
  sudo -u postgres createdb -O dhis $1
  sudo -u postgres psql -c "grant all privileges on database \"$1\" to dhis;"
  sudo -u postgres psql -c "create extension postgis;" $1
  sudo -u postgres psql -c "create extension address_standardizer;" $1
  sudo -u postgres psql -c "create extension address_standardizer_data_us;" $1
  sudo -u postgres psql -c "create extension fuzzystrmatch;" $1
  sudo -u postgres psql -c "create extension postgis_tiger_geocoder;" $1
  sudo -u postgres psql -c "create extension postgis_topology;" $1

  DHIS2_VERSION=$1
  getVersion $DHIS2_VERSION
  cp "${DB_BASE_DIR}/${DHIS2_VERSION}/${DB_FILE}.sql.gz" "${TMP_DIR}/${DB_FILE}-${1}.sql.gz"
  gunzip -f "${TMP_DIR}/${DB_FILE}-${1}.sql.gz"
  sudo -u postgres psql -d "${1}" -f "${TMP_DIR}/${DB_FILE}-${1}.sql"
  rm "${TMP_DIR}/${DB_FILE}-${1}.sql.gz"

  sleep 2
  $DIR/start-instance.sh $1
}

function analytics() {
  curl "${BASE_URL}/${1}/api/resourceTables/analytics" -X POST -u "${AUTH}"
}

function baseurl() {
  curl ${INSTANCE_BASE_URL}/$1/api/systemSettings/keyInstanceBaseUrl -X POST -H "Content-Type: text/plain" -u $AUTH -d https://play.dhis2.org/$1
}

for instance in $@; do
  validate $instance
  run $instance
  echo "Waiting 2 minutes to allow DHIS 2 to start before initiating analytics tables update"
  sleep 120
  analytics $instance
  echo "Reinit db instance done for instance: ${instance}"
done
