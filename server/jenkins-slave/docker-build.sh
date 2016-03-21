#!/bin/bash

#
# Jenkins Deployment Entry Script, will setup a running container by
#  - using a environment (configuration)    #arg 0
#  - a version identifier (build number)    #arg 1
#  - a folder containing the amak packages  #arg 2
#
# This script builds fresh images with source code for usage within non production systems.

ENVIRONMENT=$1
BUILD_NUMBER=$2
PACKAGE_SOURCE_DIR=$3


BASE=`realpath "${0%/*}"`

CONFIG_FOLDER="${BASE}/environments/${ENVIRONMENT}"
CONFIG_FILE="${CONFIG_FOLDER}/env.properties"
ACTIVE_INSTANCE_FILE="${CONFIG_FOLDER}/active"



if [ ! -f ${CONFIG_FILE} ]; then
    >&2 echo "Expected the Environment Configuration file at ${CONFIG_FILE}, but there is no file!";
    exit 1;
fi;

if [ "${BUILD_NUMBER}" == "" ]; then
    >&2 echo "You need to define a BUILD_NUMBER as thrid parameter.";
    exit 1;
fi;

if [ ! -d "${PACKAGE_SOURCE_DIR}" ]; then
    >&2 echo "Directory ${PACKAGE_SOURCE_DIR} is missing!";
    exit 1;
fi;

echo "Preparing build number $BUILD_NUMBER for $ENVIRONMENT with packages from $PACKAGE_SOURCE_DIR";

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


DATA_DIR=`getConfiguration "datadir"`;
if [ $? -eq 1 ]; then
    >&2 echo "Configuration parameter [datadir] was not set. Please check your configuration for $ENVIRONMENT.";
    exit 1;
fi;

if [ ! -d "$DATA_DIR" ]; then
    >&2 echo "Directory $DATA_DIR is not existing. Please check your configuration for [datadir] in $ENVIRONMENT.";
    exit 1
fi;

WEB_PORT=`getConfiguration "webport"`;
if [ $? -eq 1 ]; then
    >&2 echo "Configuration parameter [webport] was not set. Please check your configuration for $ENVIRONMENT.";
    exit 1;
fi;


APP_ENVIRONMENT=`getConfiguration "environment" "testing"`;



# clean used packages first
rm -R -f "$BASE/httpd/packages/"*.tar.gz

# copy current packages
cp "${PACKAGE_SOURCE_DIR}/"*.tar.gz "$BASE/httpd/packages/"


IMAGE_NAME="$ENVIRONMENT-$BUILD_NUMBER-image"
TARGET_NAME="$ENVIRONMENT-$BUILD_NUMBER"

echo "Ensure container base image is up to date...";
docker pull ubuntu:trusty

docker build -t "${IMAGE_NAME}" "${BASE}/httpd"

if [[ $? -ne 0 ]]; then
    >&2 echo "Docker build failed! Please check Dockerfile and logs...";
    exit 1;
fi;

if [ ! -f "$ACTIVE_INSTANCE_FILE" ]; then
    echo "Seems to be the first time you start this container. Instance control file will be created at $ACTIVE_INSTANCE_FILE.";
else
    OLD_NAME=`cat "$ACTIVE_INSTANCE_FILE"`
    echo "Previous Instance was named '${OLD_NAME}'."
    docker stop "${OLD_NAME}"
    docker rm "${OLD_NAME}"
fi;

echo "$TARGET_NAME" > "$ACTIVE_INSTANCE_FILE";

# start the new image
echo "docker run -d -v ${DATA_DIR}:/amak-data -v ${CONFIG_FOLDER}:/amak-config -p ${WEB_PORT}:80 -e ENVIRONMENT=$APP_ENVIRONMENT --restart=unless-stopped --name=${TARGET_NAME} ${IMAGE_NAME}"
docker run -d -v "${DATA_DIR}:/amak-data" -v "${CONFIG_FOLDER}:/amak-config" -p "${WEB_PORT}:80" -e "ENVIRONMENT=$APP_ENVIRONMENT" --restart=unless-stopped --name="${TARGET_NAME}" "${IMAGE_NAME}"

if [[ $? -ne 0 ]]; then
    >&2 echo "Failed to start container!";
    exit 1;
fi;

echo "Container ${TARGET_NAME} is online and hosting build $BUILD_NUMBER from $ENVIRONMENT in mode $APP_ENVIRONMENT."

echo "Starting docker clean now..."

docker rm $(docker ps -q -f status=exited)

IMAGEHISTORY1="${CONFIG_FOLDER}/image-1"
IMAGEHISTORY2="${CONFIG_FOLDER}/image-2"
IMAGEHISTORY3="${CONFIG_FOLDER}/image-3"

if [ -f "$IMAGEHISTORY3" ]; then
    IMAGEHISTORY3NAME=`cat "$IMAGEHISTORY3"`
    docker rmi $IMAGEHISTORY3NAME
fi;

if [ -f "$IMAGEHISTORY2" ]; then
    cp "$IMAGEHISTORY2" "$IMAGEHISTORY3"
fi;

if [ -f "$IMAGEHISTORY1" ]; then
    cp "$IMAGEHISTORY1" "$IMAGEHISTORY2"
fi;
echo "$IMAGE_NAME" > "$IMAGEHISTORY1";


docker rmi $(docker images -q -f "dangling=true")
echo "all ok..."

# display logs from current machine
docker logs ${TARGET_NAME}