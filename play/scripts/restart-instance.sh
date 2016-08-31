#!/bin/bash

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  exit 1
fi

./stop-instance.sh $@
sleep 5
./start-instance.sh $@
