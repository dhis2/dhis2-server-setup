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

  if [ ! -d /ebs1/instances/$1/resources/db.pgdump ]; then
    echo "Instance $1 does not have the required directory db.pgdump in $1/resources."
    exit 2
  fi
}

function run() {
  /home/ubuntu/scripts/stop-instance.sh $1
  sleep 5
  sudo -u postgres dropdb $1
  sudo -u postgres createdb -O dhis $1
  pg_restore -d $1 -j 4 -U dhis /ebs1/instances/$1/resources/db.pgdump
  sleep 5
  /home/ubuntu/scripts/start-instance.sh $1
}

for instance in $@; do
  validate $instance
  run $instance
done

