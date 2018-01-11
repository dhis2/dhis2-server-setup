#!/bin/bash

INSTANCE_DIR="/ebs1/instances"
INSTANCE_FILE="dhis-instance"
INSTANCE_URL="https://s3-eu-west-1.amazonaws.com/content.dhis2.org/lib/${INSTANCE_FILE}.tar.gz"

if [ $# -le 1 ]; then
  echo -e "Usage: $0 <instance> <tomcat-port-number>\n"
  exit 1
fi

function validate() {  
  if [ -d $INSTANCE_DIR/$1 ]; then
    echo "Instance $1 already exists."
    exit 1
  fi
  
  if [ $2 -lt 8000 ]; then
    echo "Port number must be greater than 8000: $2."
    exit 2
  fi
}

function create() {
  echo "Downloading instance from ${INSTANCE_URL}"
  wget --progress=bar $INSTANCE_URL -O /tmp/${INSTANCE_FILE}.tar.gz

  echo "Extracting instance archive"
  tar -zxf /tmp/${INSTANCE_FILE}.tar.gz -C $INSTANCE_DIR

  echo "Renaming instance"
  mv $INSTANCE_DIR/$INSTANCE_FILE $INSTANCE_DIR/$1

  echo "Configuring Tomcat"
  echo "DHIS2_HOME='${INSTANCE_DIR}/$1/home'" >> $INSTANCE_DIR/$1/tomcat/bin/setclasspath.sh
  echo "JAVA_HOME='/usr/lib/jvm/java-8-oracle/'" >> $INSTANCE_DIR/$1/tomcat/bin/setclasspath.sh
  echo "JAVA_OPTS='-Xmx1000m -Xms1000m'" >> $INSTANCE_DIR/$1/tomcat/bin/setclasspath.sh
  sed -i "s/Connector protocol=\"HTTP\/1.1\" port=\"8080\"/Connector protocol=\"HTTP\/1.1\" port=\"${2}\"/g" $INSTANCE_DIR/$1/tomcat/conf/server.xml

  echo "Configuring DHIS 2"
  echo "connection.url = jdbc:postgresql:$1" >> $INSTANCE_DIR/$1/home/dhis.conf
  echo "connection.username = dhis" >> $INSTANCE_DIR/$1/home/dhis.conf
  echo "connection.password = dhis" >> $INSTANCE_DIR/$1/home/dhis.conf
}

validate $1 $2
create $1 $2
