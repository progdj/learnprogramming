#!/bin/bash

#
# Jenkins Environment Command Execution Wrapper
#
# Allows to run a command within the current container instance for a configuration environment.
#
#  - environment (configuration) ex. develop       #arg 0
#  - command                     ex. du            #arg 1
#  - args                        ex. -sch /tmp     #args ...
#


ENVIRONMENT=$1
COMMAND=$2

BASE=`realpath "${0%/*}"`

ACTIVE_FILE="$BASE/environments/$ENVIRONMENT/active"

if [[ ! -f "$ACTIVE_FILE" ]]; then
    echo "The passed Environment $ENVIRONMENT is not known or there is no active container running."
    exit 1
fi;


ACTIVE_CONTAINER=`cat $ACTIVE_FILE`

docker exec -it $ACTIVE_CONTAINER $COMMAND "${@:3}"

if [[ ! $? -eq 0 ]]; then
    echo "Failed to execute '$COMMAND ${@:3}' in current instance of '$ENVIRONMENT'. (Return Code $?)";
    exit 1
else
    echo "Executed '$COMMAND ${@:3}' in current instance of '$ENVIRONMENT'. (Return Code $?)";
fi;