#!/bin/bash

#
# Jenkins Image Share Script.
#  - using a source environment (configuration)   ex. staging     #arg 0
#  - a version identifier (release number)        ex. 1.4.1       #arg 1
#  - a target host (ip/hostname)                  ex. 127.0.0.1   #arg 2
#  - a target environment (configuration)         ex. production  #arg 3
#
# This script combines the power of docker-export and docker-import.
#


ENVIRONMENT=$1
VERSION=$2
TARGET_HOST=$3
TARGET_ENVIRONMENT=$4


BASE=`realpath "${0%/*}"`

# create export from current active image in passed env...
$BASE/docker-export.sh "$ENVIRONMENT" "$VERSION"

if [[ $? -ne 0 ]]; then
    >&2 echo "Export operation failed!";
    exit 1;
fi;

# copy the generated image file to target host
TARGET_IMAGE_FILE="$BASE/transfer/amak-$VERSION"
ssh "$TARGET_HOST" -p 2255 "mkdir -p /home/jenkins/slave/transfer"
scp -P 2255 "$TARGET_IMAGE_FILE" "$TARGET_HOST:/home/jenkins/slave/transfer/"

if [[ $? -ne 0 ]]; then
    >&2 echo "Failed to copy file!";
    exit 1;
fi;

# ensure target server is up to date
ssh "$TARGET_HOST" -p 2255 "cd /home/jenkins/slave/transfer && git pull"

# import the generated image in target env
ssh "$TARGET_HOST" -p 2255 "/home/jenkins/slave/docker-import.sh $TARGET_ENVIRONMENT $VERSION"

if [[ $? -ne 0 ]]; then
    >&2 echo "Import operation failed!";
    exit 1;
fi;

#clean up
ssh "$TARGET_HOST" -p 2255 "rm /home/jenkins/slave/transfer/amak-$VERSION"
rm "$TARGET_IMAGE_FILE"