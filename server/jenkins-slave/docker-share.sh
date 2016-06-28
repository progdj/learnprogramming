#!/bin/bash

#
# Jenkins Image Share Script.
#  - using a source environment (configuration)   ex. staging                    #arg 0
#  - a tag (release number)                       ex. vrs-media/amak-1.4.1       #arg 1
#    set to this 'false' if you don't want to create a new tag and just use the existing tag...
#  - a target environment (configuration)         ex. production                 #arg 2
#  - a set of target hosts (ip/hostname)          ex. 127.0.0.1                  #arg 3-n
#
# This script uses the amak docker-control script.
#


ENVIRONMENT=$1
TAG="$2"

TARGET_ENVIRONMENT=$3
TARGET_HOST=$4
declare -a ARGUMENTS=("$@")
ARGUMENTS_TOTAL=$#
BASE=`realpath "${0%/*}"`

IMAGE_SHARE_FOLDER="/home/jenkins/slave/transfer"

if [ ${ARGUMENTS_TOTAL} -lt 4 ]; then
    >&2 echo "Wrong parameter count, please check the file header...";
    exit 1;
fi;

# create the image export folder
if [ ! -d "${IMAGE_SHARE_FOLDER}" ]; then
    mkdir -p "${IMAGE_SHARE_FOLDER}"
fi;

# if we don't create a valid tag, we will need to read the full current image-id
if [ "$TAG" == "false" ]; then
    # the target export image file
    SHARED_IMAGE_FILE="$IMAGE_SHARE_FOLDER/amak-image-$ENVIRONMENT"
    VERSION=`$BASE/docker-control.sh image-id "$ENVIRONMENT" newest`
else
    VERSION="$TAG"
fi;

# the pure version number
VERSION_NUMBER=`echo "$VERSION" | sed -E 's/.*:(.*)/\1/'`

# the target export image file
SHARED_IMAGE_FILE="${IMAGE_SHARE_FOLDER}/${ENVIRONMENT}-${VERSION_NUMBER}.image"


# export file only if not yet existing
if [ ! -f "${SHARED_IMAGE_FILE}" ]; then

    if [ "$TAG" == "false" ]; then
        # create export from current active image in passed env...
        $BASE/docker-control.sh export-image "$ENVIRONMENT" newest "${SHARED_IMAGE_FILE}"
    else
        # create export from current active image in passed env, create a tag
        $BASE/docker-control.sh export-image "$ENVIRONMENT" newest "${SHARED_IMAGE_FILE}" "$VERSION"
    fi

    if [[ $? -ne 0 ]]; then
        >&2 echo "Export operation failed!";
        exit 1;
    fi;
fi;

# Transfers the image file to the specific host.
#
# arg 0 hostname
function transferImageToHost()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        echo "Transfer to '$hostname' No need to transfer image."
    else
        echo "Transfer to '$hostname' started..."
        ssh "$hostname" -p 2255 "[ -f ${SHARED_IMAGE_FILE} ]"
        if [ $? -eq 1 ]; then
            echo "Image will be transferred to '$hostname'."
            ssh "$hostname" -p 2255 "mkdir -p ${IMAGE_SHARE_FOLDER}"
            scp -P 2255 "${SHARED_IMAGE_FILE}" "${hostname}:${IMAGE_SHARE_FOLDER}/" &
        else
            echo "Image was found on '$hostname' No need to transfer the image."
        fi;
    fi;
}

# Imports an image File at the specific host.
#
# arg 0 hostname
function importImageOnHostDocker()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        echo "Image Import on '$hostname' No need to import image."
    else
        echo "Image Import on '$hostname' started..."
        ssh "$hostname" -p 2255 "docker load < $SHARED_IMAGE_FILE" &
    fi;
}


# Imports an image File at the specific host.
#
# arg 0 hostname
function refreshDockerCode()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        echo "Amak-Docker Code update on '$hostname' skipped. (master)"
    else
        echo "Amak-Docker Code update on '$hostname' started..."
        ssh "$hostname" -p 2255 "cd /home/jenkins/amak-docker/ && git pull" &
    fi;
}

# Checks if the host can be reached by ssh.
#
# arg 0 hostname
function checkSSHConnection()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        return 0;
    else
        ssh "$hostname" -p 2255 "hostname"
        return $?
    fi;
}

# stops the current docker container for the environment
#
# arg 0 hostname
function stopCurrentContainer()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        $BASE/docker-control.sh stop "$TARGET_ENVIRONMENT"
        return $?
    else
        ssh "$hostname" -p 2255 "/home/jenkins/slave/docker-control.sh stop $TARGET_ENVIRONMENT"
        return $?
    fi;
}

# setups a new container
#
# arg 0 hostname
function setupContainer()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        $BASE/docker-control.sh setup-image "$TARGET_ENVIRONMENT" "${VERSION_NUMBER}" "$VERSION"
        return $?
    else
        ssh "$hostname" -p 2255 "/home/jenkins/slave/docker-control.sh setup-image ${TARGET_ENVIRONMENT} ${VERSION_NUMBER} $VERSION"
        return $?
    fi;
}

# setups a new container from
#
# arg 0 hostname
function deleteImageFile()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        # local image will not be deleted here, only at end of share...
        return 0
    else
        ssh "$hostname" -p 2255 "rm ${SHARED_IMAGE_FILE}"  &
    fi;
}

# start the latest container
#
# arg 0 hostname
function startLatestContainer()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        $BASE/docker-control.sh use-container "$TARGET_ENVIRONMENT" "newest"
        return $?
    else
        ssh "$hostname" -p 2255 "/home/jenkins/slave/docker-control.sh use-container $TARGET_ENVIRONMENT newest"
        return $?
    fi;
}

# start the previous container
#
# arg 0 hostname
function startPreviousContainer()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        $BASE/docker-control.sh use-container "$TARGET_ENVIRONMENT" 1
        return $?
    else
        ssh "$hostname" -p 2255 "/home/jenkins/slave/docker-control.sh use-container $TARGET_ENVIRONMENT 1"
        return $?
    fi;
}

# clean up the container history
#
# arg 0 hostname
function cleanOldContainers()
{
    local hostname=$1;

    if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
        $BASE/docker-control.sh drop-containers "$TARGET_ENVIRONMENT" 4 &
    else
        ssh "$hostname" -p 2255 "/home/jenkins/slave/docker-control.sh drop-containers $TARGET_ENVIRONMENT 4"  &
    fi;
}

# waits until container is online or 45 seconds are gone
#
# arg 0 hostname
function waitForContainerOnline()
{
    local hostname=$1;
    local timeout=300;

    try=0

    while [ "$try" -le "$timeout" ]; do
        try=$(($try+1))

        if [ "$hostname" == "127.0.0.1" ] || [ "$hostname" == "localhost" ]; then
              $BASE/environment.sh "$TARGET_ENVIRONMENT" service apache2 status
              if [ $? -eq 0 ]; then
                return 0
              fi;
        else
            ssh "$hostname" -p 2255 "/home/jenkins/slave/environment.sh "$TARGET_ENVIRONMENT" service apache2 status"
            if [ $? -eq 0 ]; then
                return 0
            fi;
        fi

        sleep 1
    done
    return 1
}



echo "Checking Connectivity..."

# check if target reachable, update docker code base and transfer the image file
for ((i=3; i<$ARGUMENTS_TOTAL; i++));
do
    checkSSHConnection ${ARGUMENTS[i]}
    if [ $? -ne 0 ]; then
        printf " - ${ARGUMENTS[i]} FAILED\n"
        printf " - SHH connection to \033[0;31m${ARGUMENTS[i]}\033[0m\n failed. Please ensure that user jenkins can connect to this server by ssh from cmd on current master server.\n"
        exit 1;
    fi;
    printf " - ${ARGUMENTS[i]} OK\n"
    refreshDockerCode ${ARGUMENTS[i]}
    transferImageToHost ${ARGUMENTS[i]}
done

echo "Waiting for previous steps (Transfer) to complete..."
wait

# import the image file on all servers
for ((i=3; i<$ARGUMENTS_TOTAL; i++));
do
    importImageOnHostDocker ${ARGUMENTS[i]}
done

echo "Waiting for previous steps (Import) to complete..."
wait

echo "Setup Containers..."

FAILURES=0;
FAIL_ON_FIRST_CONTAINER=0;
for ((i=3; i<$ARGUMENTS_TOTAL; i++));
do
    CONTAINER_SETUP=`setupContainer ${ARGUMENTS[i]}`
    RESULT=$?
    echo -e "${CONTAINER_SETUP}"
    if [ $RESULT -ne 0 ]; then
        printf " - \033[0;31m${ARGUMENTS[i]} FAILED\033[0m\n"
        FAILURES+=1
    else
        printf " - \033[0;32m${ARGUMENTS[i]} OK\033[0m\n"
    fi;
done

echo "Start Containers..."

for ((i=3; i<$ARGUMENTS_TOTAL; i++));
do
    CONTAINER_START=`startLatestContainer ${ARGUMENTS[i]}`
    RESULT=$?
    echo -e "${CONTAINER_START}"
    if [ $RESULT -ne 0 ]; then
        printf " - \033[0;31m${ARGUMENTS[i]} FAILED\033[0m\n"
        FAILURES+=1
        if [ $i -eq 3 ]; then
            printf " - \033[0;31m$First Container Start failed, will stop share now!\033[0m\n"
            break
        fi;
    else
        printf " - \033[0;32m${ARGUMENTS[i]} OK\033[0m\n"
    fi;
    if [ $i -eq 3 ]; then
        printf " - Waiting for first docker instance to come back again...\n"
        CONTAINER_ONLINE=`waitForContainerOnline ${ARGUMENTS[i]}`
        RESULT=$?
        echo -e "${CONTAINER_ONLINE}"
        if [ $RESULT -ne 0 ]; then
            printf " - \033[0;31m$First Container is not online after 45 seconds have gone, will stop share now!\033[0m\n"
            FAIL_ON_FIRST_CONTAINER=1
            break
        fi;
    fi;
done


if [ $FAIL_ON_FIRST_CONTAINER -eq 1 ]; then
    echo "Recovery from fatal build, previous container will be activated now..."
    for ((i=3; i<$ARGUMENTS_TOTAL; i++));
    do
        CONTAINER_START=`startPreviousContainer ${ARGUMENTS[i]}`
        RESULT=$?
        echo -e "${CONTAINER_START}"
        if [ $RESULT -ne 0 ]; then
            printf " - \033[0;31m${ARGUMENTS[i]} FAILED\033[0m\n"
        else
            printf " - \033[0;32m${ARGUMENTS[i]} OK\033[0m\n"
        fi;
    done
fi;

echo "Delete Images..."

for ((i=3; i<$ARGUMENTS_TOTAL; i++));
do
    deleteImageFile ${ARGUMENTS[i]}
done


echo "Waiting for previous steps (Delete Image Files) to complete..."
wait


echo "Waiting for previous steps (Delete Image Files) to complete..."
wait

if [ $FAILURES -eq 0 ]; then
    echo "Deploy completed without errors."
    if [ -f "${SHARED_IMAGE_FILE}" ]; then
        rm "${SHARED_IMAGE_FILE}";
    fi
    echo "Clean up old versions..."
    for ((i=3; i<$ARGUMENTS_TOTAL; i++));
    do
        cleanOldContainers ${ARGUMENTS[i]}
    done
    echo "Waiting for previous steps (Clean up old versions) to complete..."
    wait
    echo "All done..."
    exit 0
else
    echo "Deploy completed with errors! Please check log files..."
    exit 1
fi;