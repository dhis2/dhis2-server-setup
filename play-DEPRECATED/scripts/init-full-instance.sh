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
VERSION="DHIS2_VERSION"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  echo -e "Availalable instances:"
  ls -1 ${BASE_DIR}
  exit 1
fi

function getVersion() {
  # By default the dhis2 version is the same as the instance name
  # but that can be overridden with the contents of the DHIS2_VERSION file
  DHIS2_VERSION=$1
  if [ -e ${BASE_DIR}/$1/$VERSION ]; then
    DHIS2_VERSION=`cat ${BASE_DIR}/$1/$VERSION`
  fi
  set -- "$DHIS2_VERSION"
}

function getDBVersion() {
  # By default the dhis2 db version is the same as the instance name
  # but that can be overridden with the contents of the DHIS2_DB_VERSION file
  DHIS2_VERSION=$1
  if [ -e ${BASE_DIR}/$1/$DBVERSION ]; then
    DHIS2_VERSION=`cat ${BASE_DIR}/$1/$DBVERSION`
  fi
  set -- "$DHIS2_VERSION"
}

function validate() {
  DHIS2_VERSION=$1
  getDBVersion $DHIS2_VERSION
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
  getDBVersion $DHIS2_VERSION
  cp "${DB_BASE_DIR}/${DHIS2_VERSION}/${DB_FILE}.sql.gz" "${TMP_DIR}/${DB_FILE}-${1}.sql.gz"
  gunzip -f "${TMP_DIR}/${DB_FILE}-${1}.sql.gz"
  sudo -u postgres psql -d "${1}" -f "${TMP_DIR}/${DB_FILE}-${1}.sql"
  rm "${TMP_DIR}/${DB_FILE}-${1}.sql.gz"

  cleanWebApps $instance
  downloadWar $instance

  sleep 2
  $DIR/start-instance.sh $1
}

function cleanWebApps() {
  sudo rm -rf "${BASE_DIR}/${1}/tomcat/webapps/*"
}

function downloadWar() {
  DHIS2_VERSION=$1
  getVersion $DHIS2_VERSION
  wget --progress=bar "https://s3-eu-west-1.amazonaws.com/releases.dhis2.org/${DHIS2_VERSION}/dhis.war" -O "${BASE_DIR}/${1}/tomcat/webapps/${1}.war"
  # cp /home/ubuntu/probe.war /ebs1/instances/$1/tomcat/webapps/probe$1.war
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
