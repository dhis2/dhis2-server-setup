#!/bin/bash

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instance> <ci-job>\n"
  exit 1
fi

function validate() {
  if [ ! -d /ebs1/instances/$1 ]; then
    echo "Instance $1 does not exist."
    exit 1
  fi
}

function cleanWebApps() {
  rm -rf /ebs1/instances/$1/tomcat/webapps/*
}

function downloadWar() {
  wget --progress=bar http://ci.dhis2.org/job/dhis2-$2/lastSuccessfulBuild/artifact/dhis-2/dhis-web/dhis-web-portal/target/dhis.war -O /ebs1/instances/$1/tomcat/webapps/$1.war
}

validate $1
/home/ubuntu/scripts/stop-instance.sh $1
cleanWebApps $1
downloadWar $1 $2
/home/ubuntu/scripts/start-instance.sh $1
