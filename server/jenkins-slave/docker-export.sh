#!/bin/bash

#
# Jenkins Image Export Script, will create a tag from a version and export it.
#  - using a environment (configuration)   ex. beta        #arg 0
#  - a version identifier (release number) ex. 1.4.1       #arg 1
#
# This script saves a tested version (image) from beta or alpha for later usage within production or next stage.
#


ENVIRONMENT=$1
VERSION=$2

BASE="${0%/*}"
CONFIG_FOLDER="${BASE}/environments/${ENVIRONMENT}"
TRANSFER_FOLDER="${BASE}/transfer"


if [ ! -d "$TRANSFER_FOLDER" ]; then
    mkdir "$TRANSFER_FOLDER"
fi;

SOURCE_IMAGE=`cat "$CONFIG_FOLDER/image-1"`
TARGET_IMAGE="vrs-media/amak:$VERSION"
TARGET_IMAGE_FILE="$TRANSFER_FOLDER/amak-$VERSION"

docker tag "$SOURCE_IMAGE" "$TARGET_IMAGE"
docker save "$TARGET_IMAGE" > "$TARGET_IMAGE_FILE"

if [[ $? -ne 0 ]]; then
    >&2 echo "Failed to save image on filesystem for ${SOURCE_IMAGE}!";
    exit 1;
fi;

echo "Tag ${TARGET_IMAGE} created from ${ENVIRONMENT} ${SOURCE_IMAGE}."
echo "Exported image at $TARGET_IMAGE_FILE."