#!/bin/bash

#
# Jenkins Docker Control Script.
#
#  - perform a task                        ex. stop, start, setup-image, setup-package, use-container, drop-containers, export-image, image-id
#  - using a environment (configuration)   ex. production         #arg 1
#
# Stop or start the current (last started) container for a environment (develop).
# ./docker-control.sh stop develop
# ./docker-control.sh start develop
#
# Replace the currently executed container with the passed one, while the id defines the container id since last container build. (setup)
# 0 and newest - will be the newest build, 1 - the previous build, 2 - the build before build 1...
# ./docker-control.sh use-container develop newest
# ./docker-control.sh use-container environment revision-to-activate
#
# Drop container and (not used) images, keep only passed amount of containers for environment.
# This will keep only 4 containers and delete all older container and images.
# ./docker-control.sh drop-containers develop 4
# ./docker-control.sh drop-containers environment revisions-to-keep
#
# Build a container with a version/build identifier (58) for a specific environment (develop)
# by using the packages from a specific path (amak-*.tar.gz packages from `phing package`).
# ./docker-control.sh setup-package develop 58 /full/path/to/packages
# ./docker-control.sh setup-package environment build-id package-path
#
# Build a container with a numeric version identifier (1.5.4) for a specific environment (develop) based on passed repository image tag.
# ./docker-control.sh setup-image test 1.5.4 vrs-media/amak:1.5.4
# ./docker-control.sh setup-image environment raw-version repository/tag-name:tag-version
#
# Export the passed image history to a file (and tag it if tag param is given).
# ./docker-control.sh export-image test newest /home/jenkins/slave/transfer/image-id (vrs-media/amak:1.5.4)
# ./docker-control.sh export-image environment image-history-revision-to-tag image-save-path (tag-name:tag-version)
#
# Query the image id for a environment and revision.
# ./docker-control.sh image-id test newest
# ./docker-control.sh image-id environment image-history-revision

TASK=$1
ENVIRONMENT=$2


SERVER=`hostname`
BASE=`realpath "${0%/*}"`


CONFIG_FOLDER="${BASE}/environments/${ENVIRONMENT}"
CONFIG_FILE="${CONFIG_FOLDER}/env.properties"
ACTIVE_CONTAINER_FILE="$BASE/environments/$ENVIRONMENT/active"


if [ $# -lt 2 ]; then
    echo "Missing arguments, please check file header for details..."
    exit 1
fi;

# check if the environment is configured on this server
if [ ! -d "${CONFIG_FOLDER}" ]; then
    echo "${SERVER}: The Environment '$ENVIRONMENT' is not configured on server '${SERVER}'."
    exit 1
fi;



# check if there is a known configured container
if [ -f ${ACTIVE_CONTAINER_FILE} ]; then
    ACTIVE_CONTAINER=`cat ${ACTIVE_CONTAINER_FILE}`
else
    ACTIVE_CONTAINER="false"
fi;




# Reads a configuration setting.
#
# arg0 = name of the setting entry
# arg1 = the default value
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
    done < "${CONFIG_FILE}"

    if [ "$value" == "" ]; then
        if [ "$default" == "" ]; then
            >&2 echo "$SERVER: There is no default value for '${name}'! You must define a value for this parameter!";
            exit 1;
        else
            echo -n "${default}"
        fi;
        else
            echo -n "${value}";
    fi;
    exit 0;
}

# Add the passed container to the history file.
#
# arg 0 container id
function addContainerToHistory()
{
    local container=$1;
    local containerFile="${CONFIG_FOLDER}/container-history";

    if [ ! -f  "$containerFile" ]; then
        touch "$containerFile"
    fi;

    currentHistory=`cat "$containerFile"`;
    echo -e "$container\n$currentHistory" > $containerFile;
}

# Add the passed image to the history file.
#
# arg 0 image id
function addImageToHistory()
{
    local image=$1;
    local imageFile="${CONFIG_FOLDER}/image-history";

    if [ ! -f  "$imageFile" ]; then
        touch "$imageFile"
    fi;

    currentHistory=`cat $imageFile`;
    echo -e "$image\n$currentHistory" > $imageFile;
}


# Returns the entry from the history file
#
# arg 0 index (0 = newest..)
# arg 1 history file name
function getEntryFromHistory()
{
    local index=$1;
    local historyFile=$2;

    if [ ! -f "${historyFile}" ]; then
        echo -n "false";
        return 1
    fi;

    CURRENT_IFS="$IFS"
    IFS=$'\n' read -d '' -r -a history < $historyFile
    IFS="${CURRENT_IFS}"

    if [ ${#history[@]} -eq 0 ]; then
        echo -n "false";
        return 1
    fi;

    if [ "$index" == "newest" ]; then
        echo -n "${history[0]}";
        return 0
    else
        if [ ${#history[@]} -le $index ]; then
            echo -n "false";
            return 1
        else
            echo -n "${history[$index]}";
        fi;
    fi;
    return 0
}

# Reduces the history for a file.
#
# arg 0 entries to keep
# arg 1 history file name
# arg 2 action to perform for each deleted entry
function reduceHistory()
{
    local revisions=$1;
    local historyFile=$2;
    local action=$3;

    local entries=`cat $historyFile | wc -l`;

    if [ $revisions -lt $entries ]; then
        for ((i=$entries;i>$revisions;i-=1)) ; do
            entry="$(($i-1))"
            entryValue=`getEntryFromHistory $entry $historyFile`
            $action "$entryValue"
            printf "$action $entryValue\n"
        done
        historyToKeep=`head -n $revisions $historyFile`
        echo -e "$historyToKeep" > $historyFile;
    fi;
}

#
# Stop a running container...
#
if [ "$TASK" == "stop" ]; then
    if [ "${ACTIVE_CONTAINER}" != "false" ]; then
        docker stop "${ACTIVE_CONTAINER}"
        echo "$SERVER: Stopped container '${ACTIVE_CONTAINER}' for Environment '${ENVIRONMENT}'."
        exit 0
    else
        echo "$SERVER: There is no known container for Environment '${ENVIRONMENT}'."
        exit 1
    fi;
fi;


#
# Start a running container...
#
if [ "$TASK" == "start" ]; then
    if [ "${ACTIVE_CONTAINER}" != "false" ]; then
        docker start "${ACTIVE_CONTAINER}"
        echo "$SERVER: Started container '${ACTIVE_CONTAINER}' for Environment '${ENVIRONMENT}'."
        exit 0
    else
        echo "$SERVER: There is no known active container for Environment '${ENVIRONMENT}'. Try running 'docker-control use-container ${ENVIRONMENT} newest'."
        exit 1
    fi;
fi;

#
# delete old containers
#
if [ "$TASK" == "drop-containers" ]; then
    if [ $# -lt 3 ]; then
        echo "$SERVER: Missing arguments, please specify the revisions to keep..."
        exit 1
    fi;
    REVISIONS_TO_KEEP=$3
    if [ ${REVISIONS_TO_KEEP} -lt 1 ]; then
        echo "$SERVER: There must be at least one revision left..."
        exit 1
    fi;

    CONTAINER=`(reduceHistory "${REVISIONS_TO_KEEP}" ${CONFIG_FOLDER}/container-history "docker rm")`
    IMAGES=`(reduceHistory "${REVISIONS_TO_KEEP}" ${CONFIG_FOLDER}/image-history "docker rmi")`
    echo -e "$CONTAINER"
    echo -e "$IMAGES"
    echo "$SERVER: Deleting Untagged Images..."
    docker rmi $(docker images -q -f "dangling=true")
    exit 0
fi;


#
# replace running container with passed revision
#
if [ "$TASK" == "use-container" ]; then
    if [ $# -lt 3 ]; then
        echo "Missing arguments, please specify the revision to activate..."
        exit 1
    fi;

    REVISION_TO_ACTIVATE=$3

    CONTAINER_TO_ACTIVATE=`getEntryFromHistory ${REVISION_TO_ACTIVATE} ${CONFIG_FOLDER}/container-history`
    if [ "${CONTAINER_TO_ACTIVATE}" == "false" ]; then
        echo "$SERVER: There is no known container in history at index ${REVISION_TO_ACTIVATE}  for Environment '${ENVIRONMENT}'."
        exit 1
    fi;

    if [ "${ACTIVE_CONTAINER}" != "false" ]; then
        echo "$SERVER: Stopping current container ${ACTIVE_CONTAINER}..."
        docker stop "${ACTIVE_CONTAINER}"
    fi;


    echo "$SERVER: Starting container ${CONTAINER_TO_ACTIVATE}..."
    docker start "${CONTAINER_TO_ACTIVATE}"
    if [ $? -eq 0 ]; then
        echo "${CONTAINER_TO_ACTIVATE}" > ${ACTIVE_CONTAINER_FILE}
        docker logs "${CONTAINER_TO_ACTIVATE}"
        exit 0
    else
        echo "$SERVER: Starting container ${CONTAINER_TO_ACTIVATE} for Environment '${ENVIRONMENT}' failed!"
        exit 1
    fi;
fi;



#
# tag an image and export it to a file
#
if [ "$TASK" == "export-image" ]; then
    if [ $# -lt 4 ]; then
        echo "Missing arguments, please read the file header for more details..."
        exit 1
    fi;

    IMAGE_REVISION_TO_ACTIVATE=$3
    IMAGE_FILE_NAME=$4

    IMAGE_TO_TAG=`getEntryFromHistory ${IMAGE_REVISION_TO_ACTIVATE} ${CONFIG_FOLDER}/image-history`
    if [ "${IMAGE_TO_TAG}" == "false" ]; then
        echo "$SERVER: There is no known image in history at index ${IMAGE_REVISION_TO_ACTIVATE}  for Environment '${ENVIRONMENT}'."
        exit 1
    fi;

    # create a tag if tag param present
    if [ $# -eq 5 ]; then
        TAG_NAME="$5"
        docker tag "$IMAGE_TO_TAG" "$TAG_NAME"
        echo "Created a tag from ${IMAGE_TO_TAG} named (${TAG_NAME}).";
    else
        TAG_NAME="$IMAGE_TO_TAG"
    fi

    # save the image
    docker save "$TAG_NAME" > "$IMAGE_FILE_NAME"

    if [[ $? -ne 0 ]]; then
        >&2 echo "Failed to save image on filesystem for ${IMAGE_TO_TAG}!";
        exit 1;
    fi;

    echo "Exported image at $IMAGE_FILE_NAME."
    exit 0
fi;

#
# display the repository tag for an image from history
#
if [ "$TASK" == "image-id" ]; then
    IMAGE_REVISION_TO_DISPLAY=$3
    IMAGE_ID=`getEntryFromHistory ${IMAGE_REVISION_TO_DISPLAY} ${CONFIG_FOLDER}/image-history`
    if [ "${IMAGE_ID}" == "false" ]; then
        echo "$SERVER: There is no known image in history at index ${IMAGE_REVISION_TO_DISPLAY}  for Environment '${ENVIRONMENT}'."
        exit 1
    fi;
    echo "$IMAGE_ID"
    exit 0
fi;


#
# Setup a container for the environment by image or package...
#
if [ "$TASK" == "setup-image" ] || [ "$TASK" == "setup-package" ]; then

    CONTAINER_NAME="${ENVIRONMENT}-$3"

    if [ "$TASK" == "setup-package" ]; then
        PACKAGE_SOURCE_DIR=$4
        DOCKER_IMAGE="vrs-media-${ENVIRONMENT}/build:$3"
        if [ $# -ne 4 ]; then
            echo "Wrong parameter count, please read head of this file..."
            exit 1;
        fi;
        if [ ! -d "${PACKAGE_SOURCE_DIR}" ]; then
            echo "Package source directory ${PACKAGE_SOURCE_DIR} is not existing!"
            exit 1;
        fi;
    fi;

    if [ "$TASK" == "setup-image" ]; then
        if [ $# -ne 4 ]; then
            echo "Wrong parameter count, please read head of this file..."
            exit 1;
        fi;
        DOCKER_IMAGE="$4"
    fi;


    AMAK_DATA_DIR=`getConfiguration "amak.datadir"`;
    if [ $? -eq 1 ]; then
        >&2 echo "$SERVER: Configuration parameter [amak.datadir] was not set. Please check your configuration for $ENVIRONMENT.";
        exit 1;
    fi;

    if [ ! -d "${AMAK_DATA_DIR}" ]; then
        >&2 echo "$SERVER: Directory ${AMAK_DATA_DIR} is not existing. Please check your configuration for [amak.datadir] in $ENVIRONMENT.";
        exit 1
    fi;

    PORTAL_DATA_DIR=`getConfiguration "portal.datadir"`;
    if [ $? -eq 1 ]; then
        >&2 echo "$SERVER: Configuration parameter [portal.datadir] was not set. Please check your configuration for $ENVIRONMENT.";
        exit 1;
    fi;

    if [ ! -d "${PORTAL_DATA_DIR}" ]; then
        >&2 echo "Directory ${PORTAL_DATA_DIR} is not existing. Please check your configuration for [portal.datadir] in $ENVIRONMENT.";
        exit 1
    fi;

    WEB_PORT=`getConfiguration "webport"`;
    if [ $? -eq 1 ]; then
        >&2 echo "$SERVER: Configuration parameter [webport] was not set. Please check your configuration for $ENVIRONMENT.";
        exit 1;
    fi;


    APP_ENVIRONMENT=`getConfiguration "environment" "testing"`;

    if [ "$TASK" == "setup-package" ]; then

        # clean used packages first
        rm -R -f "$BASE/httpd/packages/"*.tar.gz

        # copy current packages
        cp "${PACKAGE_SOURCE_DIR}/"*.tar.gz "$BASE/httpd/packages/"

        echo "$SERVER: Ensure container base image is up to date...";
        docker pull ubuntu:trusty

        # build a image with packages
        docker build -t "${DOCKER_IMAGE}" "${BASE}/httpd"

        if [[ $? -ne 0 ]]; then
            >&2 echo "$SERVER: Docker build failed! Please check Dockerfile and logs...";
            exit 1;
        fi;

    fi;


    # create a container
    echo "$SERVER: docker create -v ${AMAK_DATA_DIR}:/amak-data -v ${PORTAL_DATA_DIR}:/portal-data -v ${CONFIG_FOLDER}:/amak-config -p ${WEB_PORT}:80 -e ENVIRONMENT=${APP_ENVIRONMENT} --restart=unless-stopped --name=${CONTAINER_NAME} ${DOCKER_IMAGE}"
    docker create -v "${AMAK_DATA_DIR}:/amak-data" -v ${PORTAL_DATA_DIR}:/portal-data -v "${CONFIG_FOLDER}:/amak-config" -p "${WEB_PORT}:80" -e "ENVIRONMENT=${APP_ENVIRONMENT}" --restart=unless-stopped --name="${CONTAINER_NAME}" "${DOCKER_IMAGE}"

    if [[ $? -ne 0 ]]; then
        >&2 echo "$SERVER: Failed to create the container!";
        exit 1;
    fi;

    addImageToHistory "${DOCKER_IMAGE}"
    addContainerToHistory "${CONTAINER_NAME}"
    echo "$SERVER: Container ${CONTAINER_NAME} was created from image ${DOCKER_IMAGE} with Environment Config from '${ENVIRONMENT}'. Application mode is ${APP_ENVIRONMENT}."
    exit 0
fi