#!/bin/bash

# INIT
. env.sh

# GLOBALS
# ---
# BASE_DIR

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instances...>\n"
  exit 1
fi

function validate() {
  if [ ! -d "${BASE_DIR}/${1}" ]; then
    echo "Instance $1 does not exist."
    exit 1
  fi
}

function run() {
  local t=$1
  $DIR/stop-instance.sh "$t"
  sleep 5
  $DIR/start-instance.sh "$t"
}

for instance in $@; do
  validate $instance
  run $instance
done
