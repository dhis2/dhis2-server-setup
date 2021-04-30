#!/bin/bash

S3_STABLE=""
S3_CANARY=""
S3_CANARY_DATE=""
S3_DEV=""
S3_LEGACY=""
S3_EOS=""

WAR_LOCATION="/ebs1/home/jenkins/workspace/${JOB_NAME}/dhis-2/dhis-web/dhis-web-portal/target/dhis.war"

BRANCH=$1
PATCH=""
if [[ "$2" != "" ]]
then
  PATCH=$1
  BRANCH=${2/%\//}
fi

echo " SOURCE WAR   = ${WAR_LOCATION}"
if [ ! -f ${WAR_LOCATION} ]; then
  echo "War file not found. Exiting."
  exit 1
fi

echo " BRANCH       = ${BRANCH}"


if [[ "$PATCH" != "" ]]
then
  echo " PATCH        = ${PATCH}"
  # copy to the stable channel
  S3_STABLE="s3://releases.dhis2.org/${BRANCH}/dhis2-stable-${PATCH}.war"
  S3_LEGACY="s3://releases.dhis2.org/${BRANCH}/${PATCH}/dhis.war"
else
  S3_DATE=`date -I'date'`
  S3_LEGACY="s3://releases.dhis2.org/${BRANCH}/dhis.war"
  if [[ "$BRANCH" == "dev" ]]; then
    # use master instead of dev for the new schemas
    BRANCH="master"
  fi
  S3_CANARY="s3://releases.dhis2.org/${BRANCH}/canary/dhis2-canary-${BRANCH}.war"
  S3_CANARY_DATE="s3://releases.dhis2.org/${BRANCH}/canary/dhis2-canary-${BRANCH}-${S3_DATE}.war"
  S3_DEV="s3://releases.dhis2.org/${BRANCH}/dev/dhis2-dev-${BRANCH}.war"

  for V in "2.31" "2.32"
  do	
    if [[ "$BRANCH" == "$V" ]]; then
    # create the "eos" copy
    S3_EOS="s3://releases.dhis2.org/${BRANCH}/dhis2-stable-${BRANCH}-eos.war"
    fi
  done
  
fi

echo "====================================="
echo " STABLE       = ${S3_STABLE}"
echo " CANARY       = ${S3_CANARY}"
echo " CANARY+DATE  = ${S3_CANARY_DATE}"
echo " DEV          = ${S3_DEV}"
echo " LEGACY       = ${S3_LEGACY}"
echo " EOS          = ${S3_EOS}"
echo "====================================="


if [[ "${S3_STABLE}" != "" ]]; then
  ~/.local/bin/aws s3 cp $WAR_LOCATION $S3_STABLE --metadata "git-commit=$GIT_COMMIT"
fi
if [[ "${S3_CANARY_DATE}" != "" ]]; then
  if [[ $(~/.local/bin/aws s3 ls ${S3_CANARY_DATE} | wc -l) == 0 ]];then
    ~/.local/bin/aws s3 cp $WAR_LOCATION $S3_CANARY_DATE --metadata "git-commit=$GIT_COMMIT"
    ~/.local/bin/aws s3 cp $WAR_LOCATION $S3_CANARY --metadata "git-commit=$GIT_COMMIT"
  fi
fi
if [[ "${S3_DEV}" != "" ]]; then
  ~/.local/bin/aws s3 cp $WAR_LOCATION $S3_DEV --metadata "git-commit=$GIT_COMMIT"
fi
if [[ "${S3_LEGACY}" != "" ]]; then
  ~/.local/bin/aws s3 cp $WAR_LOCATION $S3_LEGACY --metadata "git-commit=$GIT_COMMIT"
fi
if [[ "${S3_EOS}" != "" ]]; then
  ~/.local/bin/aws s3 cp $WAR_LOCATION $S3_EOS --metadata "git-commit=$GIT_COMMIT"
fi
