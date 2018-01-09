#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTANCE_DIR="/ebs1/instances"
TOMCAT_FILENAME="apache-tomcat-8.5.24"
TOMCAT_URL="https://s3-eu-west-1.amazonaws.com/content.dhis2.org/lib/${TOMCAT_FILENAME}.tar.gz"

if [ $# -eq 0 ]; then
  echo -e "Usage: $0 <instance>\n"
  exit 1
fi

function validate() {
  if [ -d $INSTANCE_DIR/$1 ]; then
    echo "Instance $1 already exists."
    exit 1
  fi
}

function create() {
	echo "Downloading Tomcat from ${TOMCAT_URL}"
	wget --progress=bar $TOMCAT_URL -O /tmp/${TOMCAT_FILENAME}.tar.gz

	echo "Extracting Tomcat archive"
	tar -zxvf /tmp/${TOMCAT_FILENAME}.tar.gz -C $INSTANCE_DIR
	
	echo "Renaming Tomcat instance"
	mv $INSTANCE_DIR/$TOMCAT_FILENAME $INSTANCE_DIR/$1

}

validate $1
create $1
