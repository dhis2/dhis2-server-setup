#!/bin/bash

# INIT
. env.sh

# GLOBALS
# ---
# BASE_DIR

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  exit 1
fi

tail -f "${BASE_DIR}/${1}/tomcat/logs/catalina.out" -n 1000
