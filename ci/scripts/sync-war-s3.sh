#!/bin/bash

S3_STABLE=""
S3_CANARY=""
S3_CANARY_DATE=""
S3_DEV=""
S3_LEGACY=""
S3_EOS=""
S3_BUCKET="s3://releases.dhis2.org"


WAR_LOCATION="${WORKSPACE}/dhis-2/dhis-web/dhis-web-portal/target/dhis.war"

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
  S3_STABLE="${S3_BUCKET}/${BRANCH}/dhis2-stable-${PATCH}.war"
  S3_LEGACY="${S3_BUCKET}/${BRANCH}/${PATCH}/dhis.war"
else
  S3_DATE=`date -I'date'`
  if [[ "$BRANCH" == "master" ]]; then
    S3_LEGACY="${S3_BUCKET}/dev/dhis.war"
  else
    S3_LEGACY="${S3_BUCKET}/${BRANCH}/dhis.war"
  fi
  S3_CANARY="${S3_BUCKET}/${BRANCH}/canary/dhis2-canary-${BRANCH}.war"
  S3_CANARY_DATE="${S3_BUCKET}/${BRANCH}/canary/dhis2-canary-${BRANCH}-${S3_DATE}.war"
  S3_DEV="${S3_BUCKET}/${BRANCH}/dev/dhis2-dev-${BRANCH}.war"

  for V in "2.31" "2.32" "2.33"
  do	
    if [[ "$BRANCH" == "$V" ]]; then
      # create the "eos" copy
      S3_EOS="${S3_BUCKET}/${BRANCH}/dhis2-stable-${BRANCH}-eos.war"
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
  aws s3 cp $WAR_LOCATION $S3_STABLE --metadata "git-commit=$GIT_COMMIT"
fi
if [[ "${S3_CANARY_DATE}" != "" ]]; then
  if [[ $(aws s3 ls ${S3_CANARY_DATE} | wc -l) == 0 ]]; then
    aws s3 cp $WAR_LOCATION $S3_CANARY_DATE --metadata "git-commit=$GIT_COMMIT"
    aws s3 cp $WAR_LOCATION $S3_CANARY --metadata "git-commit=$GIT_COMMIT"
  fi
fi
if [[ "${S3_DEV}" != "" ]]; then
  aws s3 cp $WAR_LOCATION $S3_DEV --metadata "git-commit=$GIT_COMMIT"
fi
if [[ "${S3_LEGACY}" != "" ]]; then
  aws s3 cp $WAR_LOCATION $S3_LEGACY --metadata "git-commit=$GIT_COMMIT"
fi
if [[ "${S3_EOS}" != "" ]]; then
  aws s3 cp $WAR_LOCATION $S3_EOS --metadata "git-commit=$GIT_COMMIT"
fi
