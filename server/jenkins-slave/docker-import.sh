#!/bin/bash

#
# Jenkins Image Import Script, will create a running container by importing a image.
#  - using a environment (configuration)   ex. production  #arg 0
#  - a version identifier (release number) ex. 1.4.1       #arg 1
#
# This script setups a tested version (image) from beta or alpha to use with production or stage parameters.
#


ENVIRONMENT=$1
VERSION=$2

BASE=`realpath "${0%/*}"`
CONFIG_FOLDER="${BASE}/environments/${ENVIRONMENT}"
TRANSFER_FOLDER="${BASE}/transfer"


if [ ! -d "$TRANSFER_FOLDER" ]; then
    mkdir "$TRANSFER_FOLDER"
fi;

SOURCE_IMAGE="vrs-media/amak:$VERSION"
SOURCE_IMAGE_FILE="$TRANSFER_FOLDER/amak-$VERSION"


if [ ! -f "$SOURCE_IMAGE_FILE" ]; then
    >&2 echo "Expected the image file for version ${VERSION} at ${SOURCE_IMAGE_FILE} but there is no file!";
    exit 1;
fi;

docker load < "$SOURCE_IMAGE_FILE"

#
# Use the imported image to create a running container again...
#
CONFIG_FILE="${CONFIG_FOLDER}/env.properties"
ACTIVE_INSTANCE_FILE="${CONFIG_FOLDER}/active"



if [ ! -f ${CONFIG_FILE} ]; then
    >&2 echo "Expected the Environment Configuration file at ${CONFIG_FILE}, but there is no file!";
    exit 1;
fi;


echo "Setup ${SOURCE_IMAGE} as a container for ${ENVIRONMENT}...";

function getConfiguration() {
    local name=$1;
    local default=$2;
    local value="";

    while read -r line || [[ -n "$line" ]]; do
        IFS="=";
        config=($line);
        configKey=${config[0]};
        configValue=${config[1]};
        if [ "$configKey" == "$name" ]; then
            value="${configValue}";
            break;
        fi;
    done < ${CONFIG_FILE}

    if [ "$value" == "" ]; then
        if [ "$default" == "" ]; then
            >&2 echo "There is no default value for '${name}'! You must define a value for this parameter!";
            exit 1;
        else
            echo -n "${default}"
        fi;
        else
            echo -n "${value}";
    fi;
    exit 0;
}


AMAK_DATA_DIR=`getConfiguration "amak.datadir"`;
if [ $? -eq 1 ]; then
    >&2 echo "Configuration parameter [amak.datadir] was not set. Please check your configuration for $ENVIRONMENT.";
    exit 1;
fi;

if [ ! -d "$AMAK_DATA_DIR" ]; then
    >&2 echo "Directory $AMAK_DATA_DIR is not existing. Please check your configuration for [amak.datadir] in $ENVIRONMENT.";
    exit 1
fi;

PORTAL_DATA_DIR=`getConfiguration "portal.datadir"`;
if [ $? -eq 1 ]; then
    >&2 echo "Configuration parameter [portal.datadir] was not set. Please check your configuration for $ENVIRONMENT.";
    exit 1;
fi;

if [ ! -d "$PORTAL_DATA_DIR" ]; then
    >&2 echo "Directory $PORTAL_DATA_DIR is not existing. Please check your configuration for [portal.datadir] in $ENVIRONMENT.";
    exit 1
fi;

WEB_PORT=`getConfiguration "webport"`;
if [ $? -eq 1 ]; then
    >&2 echo "Configuration parameter [webport] was not set. Please check your configuration for $ENVIRONMENT.";
    exit 1;
fi;


APP_ENVIRONMENT=`getConfiguration "environment" "testing"`;

TARGET_NAME="$ENVIRONMENT-$VERSION"

if [ ! -f "$ACTIVE_INSTANCE_FILE" ]; then
    echo "Seems to be the first time you start this container. Instance control file will be created at $ACTIVE_INSTANCE_FILE.";
else
    OLD_NAME=`cat "$ACTIVE_INSTANCE_FILE"`
    echo "Previous Instance was named '${OLD_NAME}'."
    docker stop "${OLD_NAME}"
    docker rm "${OLD_NAME}"
fi;

echo "$TARGET_NAME" > "$ACTIVE_INSTANCE_FILE";

# start the image
echo "docker run -d -v ${AMAK_DATA_DIR}:/amak-data -v ${PORTAL_DATA_DIR}:/portal-data -v ${CONFIG_FOLDER}:/amak-config -p ${WEB_PORT}:80 -e ENVIRONMENT=$APP_ENVIRONMENT --restart=unless-stopped --name=${TARGET_NAME} ${SOURCE_IMAGE}"
docker run -d -v "${AMAK_DATA_DIR}:/amak-data" -v ${PORTAL_DATA_DIR}:/portal-data -v "${CONFIG_FOLDER}:/amak-config" -p "${WEB_PORT}:80" -e "ENVIRONMENT=$APP_ENVIRONMENT" --restart=unless-stopped --name="${TARGET_NAME}" "${SOURCE_IMAGE}"

if [[ $? -ne 0 ]]; then
    >&2 echo "Failed to start container!";
    exit 1;
fi;

echo "Container ${TARGET_NAME} is online and hosting image $SOURCE_IMAGE with env from $ENVIRONMENT in mode $APP_ENVIRONMENT."

# display logs from current machine
docker logs "${TARGET_NAME}"