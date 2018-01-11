#!/bin/bash

INSTANCE_BASE_DIR="/ebs1/instances"

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  exit 1
fi

tail -f $INSTANCE_BASE_DIR/$1/tomcat/logs/catalina.out -n 1000
