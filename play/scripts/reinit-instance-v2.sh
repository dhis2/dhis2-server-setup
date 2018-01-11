#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  exit 1
fi

function validate() {
  if [ ! -d /ebs1/instances/$1 ]; then
    echo "Instance $1 does not exist."
    exit 1
  fi
}

function cleanWebApps() {
  sudo rm -rf /ebs1/instances/$1/tomcat/webapps/*
}

function downloadWar() {
  wget --progress=bar https://s3-eu-west-1.amazonaws.com/releases.dhis2.org/$1/dhis.war -O /ebs1/instances/$1/tomcat/webapps/$1.war
}

for instance in $@; do
  validate $instance
  $DIR/stop-instance.sh $instance
  cleanWebApps $instance
  downloadWar $instance
  $DIR/start-instance.sh $instance
done
