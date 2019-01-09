#!/bin/bash

TMP_DIR="/ebs1/tmp"
INSTANCE_DIR="/ebs1/instances"
INSTANCE_FILE="dhis-instance"
INSTANCE_URL="https://s3-eu-west-1.amazonaws.com/content.dhis2.org/lib/${INSTANCE_FILE}.tar.gz"

if [ $# -le 1 ]; then
  echo -e "Usage: $0 <instance> <tomcat-port-number> [<dhis2-release-version>]\n"
  echo -e "       dhis2-release-version may be in the format <version> or <version>/<tag>"
  echo -e "       e.g. '2.31' or '2.31/2.31.2'\n"
  exit 1
fi

DHIS2_VERSION=$1
if [ ! -z "$3" ]; then
  DHIS2_VERSION=$3
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

  if [ $2 -gt 9000 ]; then
    echo "Port number must be less than 9000: $2."
    exit 2
  fi
}

function create() {
  PORT=$2
  SHUTDOWN_PORT=$(($2+1000))
  echo "Using HTTP port: ${PORT} and shutdown port: ${SHUTDOWN_PORT}"

  echo "Downloading instance from ${INSTANCE_URL}"
  wget --progress=bar $INSTANCE_URL -O ${TMP_DIR}/${INSTANCE_FILE}.tar.gz

  echo "Extracting instance archive"
  tar -zxf ${TMP_DIR}/${INSTANCE_FILE}.tar.gz -C $INSTANCE_DIR

  echo "Renaming instance"
  mv $INSTANCE_DIR/$INSTANCE_FILE $INSTANCE_DIR/$1
  echo $DHIS2_VERSION > $INSTANCE_DIR/$1/DHIS2_VERSION
  echo $DHIS2_VERSION > $INSTANCE_DIR/$1/DHIS2_DB_VERSION

  echo "Configuring Tomcat"
  echo "export DHIS2_HOME='${INSTANCE_DIR}/$1/home'" >> $INSTANCE_DIR/$1/tomcat/bin/setclasspath.sh
  echo "export JAVA_HOME='/usr/lib/jvm/java-8-oracle/'" >> $INSTANCE_DIR/$1/tomcat/bin/setclasspath.sh
  echo "export JAVA_OPTS='-Xmx1500m -Xms1000m'" >> $INSTANCE_DIR/$1/tomcat/bin/setclasspath.sh
  sed -i "s/Server port=\"8005\" shutdown=\"SHUTDOWN\"/Server port=\"${SHUTDOWN_PORT}\" shutdown=\"SHUTDOWN\"/g" $INSTANCE_DIR/$1/tomcat/conf/server.xml
  sed -i "s/Connector protocol=\"HTTP\/1.1\" port=\"8080\"/Connector protocol=\"HTTP\/1.1\" port=\"${PORT}\"/g" $INSTANCE_DIR/$1/tomcat/conf/server.xml

  echo "Configuring DHIS 2"
  echo "connection.url = jdbc:postgresql:$1" >> $INSTANCE_DIR/$1/home/dhis.conf
  echo "connection.username = dhis" >> $INSTANCE_DIR/$1/home/dhis.conf
  echo "connection.password = dhis" >> $INSTANCE_DIR/$1/home/dhis.conf
}

validate $1 $2
create $1 $2
