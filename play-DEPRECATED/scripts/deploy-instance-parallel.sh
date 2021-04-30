#!/bin/bash

# INIT
. env.sh

# GLOBALS
# ---
# BASE_DIR
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

function validate() {
  if [ ! -d "${BASE_DIR}/${1}" ]; then
    echo "Instance $1 does not exist."
    exit 1
  fi
}

function nextContextVersion() {
  #sudo rm -rf "${BASE_DIR}/${1}/tomcat/webapps/*"
  version=`find ${BASE_DIR}/${1}/tomcat/webapps/ -maxdepth 1 -name '${1}#*.war' | tail -n1 | sed -n 's/.*##\(.*\)\.war/\1/p'`
  printf %04d.war $((version+1))
}

function downloadWar() {
  DHIS2_VERSION=$1
  getVersion $DHIS2_VERSION
  contextVersion=`nextContextVersion`
  wget --progress=bar "https://releases.dhis2.org/${DHIS2_VERSION}/dhis.war" -O "${BASE_DIR}/${1}/tomcat/webapps/${1}##${contextVersion}.war"
  # cp /home/ubuntu/probe.war /ebs1/instances/$1/tomcat/webapps/probe$1.war
}

for instance in $@; do
  validate $instance
  downloadWar $instance
done
