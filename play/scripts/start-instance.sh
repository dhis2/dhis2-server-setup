#!/bin/bash

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

function run() {
  CATALINA_PID="/var/run/tomcat/$1.pid" /ebs1/instances/$1/tomcat/bin/startup.sh
}

for instance in $@; do
  validate $instance
  run $instance
done

