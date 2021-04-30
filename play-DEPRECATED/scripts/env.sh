#!/bin/bash

if [[ ! -n ${TMP_DIR:-} ]]; then
    export TMP_DIR="/ebs1/tmp"
fi

if [[ ! -n ${BASE_DIR:-} ]]; then
    export BASE_DIR="/ebs1/instances"
fi

if [[ ! -n ${BASE_URL:-} ]]; then
    export BASE_URL="https://play.dhis2.org"
fi

if [[ ! -n ${DB_BASE_DIR:-} ]]; then
    export DB_BASE_DIR="/ebs1/databases/sierra-leone"
fi

if [[ ! -n ${DB_FILE:-} ]]; then
    export DB_FILE="dhis2-db-sierra-leone"
fi

if [[ ! -n ${AUTH:-} ]]; then
    export AUTH="system:System123"
fi

if [[ ! -n ${JENKINS_WORKSPACE:-} ]]; then
    export JENKINS_WORKSPACE="/ebs1/jenkins/workspace"
fi

if [[ ! -n ${WAR_LOCATION:-} ]]; then
    export WAR_LOCATION="${JENKINS_WORKSPACE}/dhis2-${1}/dhis-2/dhis-web/dhis-web-portal/target/dhis.war"
fi

if [[ ! -n ${S3_LOCATION:-} ]]; then
    export S3_LOCATION="s3://releases.dhis2.org/${1}/dhis.war"
fi
