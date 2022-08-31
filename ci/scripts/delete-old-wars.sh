#!/usr/bin/env bash

set -euxo pipefail

version="$1"

type="canary"

prefix="$version/$type"

bucket="releases.dhis2.org"

versions_json="https://releases.dhis2.org/v1/versions/stable.json"


latest_patch=$(
  curl -fsSL "$versions_json" |
  jq -r --arg version "$version" \
    '.versions[] | select(.name == $version ) | .latestPatchVersion'
)

last_supported_patch=$(($latest_patch - 2))

last_supported_date=$(
  curl -fsSL "$versions_json" |
  jq -r --arg version "$version" \
    --arg patch "$last_supported_patch" \
    'last(.versions[] | select(.name == $version) | .patchVersions[] | select(.version == ($patch|tonumber)) | .releaseDate)'
)

if [[ "$version" == "master" ]]; then
  last_supported_date=$(date -d "-1 month" +%Y-%m-%d)
fi

aws s3api list-object-versions \
  --bucket "$bucket" \
  --prefix "$prefix" \
  --query "Versions[?LastModified < \`$last_supported_date\`]" |
jq '{Objects: [.[] | {Key: .Key, VersionId: .VersionId}]}' > old-wars.json

number_of_objects=$(jq -r '.Objects | length' old-wars.json)

if [[ "$number_of_objects" -gt 0 ]]; then
  echo "Deleting $number_of_objects objects ..."
  aws s3api delete-objects \
    --bucket "$bucket" \
    --delete file://old-wars.json
else
  echo "Nothing to delete."
fi
