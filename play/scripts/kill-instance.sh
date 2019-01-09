#!/bin/bash

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  exit 1
fi

function killInstance() {
  PID=`ps aux|grep /ebs1/instances/$1/tomcat|grep -v grep|awk '{ print $2 }'`

  if [ -n "$PID" ]; then
    sudo kill -9 $PID
  fi
}

for instance in $@; do
  killInstance $instance
done

