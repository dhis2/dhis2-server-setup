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
    '.versions[] | select(.name == $version) | .patchVersions[] | select(.version == ($patch|tonumber)) | .releaseDate'
)

aws s3api list-object-versions --bucket "$bucket" --prefix "$prefix" --max-items=3 --query 'Versions[?LastModified < `'$last_supported_date'`]' | jq '{Objects: [ .[] | {Key: .Key, VersionId: .VersionId} ] }' > old-wars.json

aws s3api list-object-versions \
  --bucket "$bucket" \
  --prefix "$prefix" \
  --max-items=3 \
  --query 'Versions[?LastModified < `'$last_supported_date'`]' |
  jq '{Objects: [ .[] | {Key: .Key, VersionId: .VersionId} ] }' > old-wars.json

aws s3api delete-objects \
  --bucket "$bucket" \
  --delete file://old-wars.json
