#!/bin/bash

# check for failing migrations

# waits until service is online or 300 seconds are gone
function waitForServiceOnline()
{
    local timeout=300;
    try=0
    while [ "$try" -le "$timeout" ]; do
        try=$(($try+1))
        service apache2 status
        if [ $? -eq 0 ]; then
            return 0
        fi;
        sleep 1
    done
    return 1
}


waitForServiceOnline

RESULT=$?
if [ $RESULT -ne 0 ]; then
    >&2 echo "ERROR: Service is not online!";
    exit 1
fi;

FAILED_MIGRATIONS=0

if [ -d /var/www/amak-frontend ]; then
    cd /var/www/amak-frontend
    php yiic migrate --interactive=0
    if [ $? -ne 0 ]; then
        >&2 echo -e "\n\nERROR: Package amak-frontend contains failing migrations!";
        FAILED_MIGRATIONS=1
    fi;
fi;


if [ -d /var/www/amak-portal ]; then
    cd /var/www/amak-portal
    php yiic migrate --interactive=0
    if [ $? -ne 0 ]; then
        >&2 echo -e "\n\nERROR: Package amak-portal contains failing migrations!";
        FAILED_MIGRATIONS=1
    fi;
fi;

if [ ${FAILED_MIGRATIONS} -eq 1 ]; then
    >&2 echo -e "\n\nERROR: Build contains failing migrations!";
    exit 1
else
    echo "Migrations are ok.";
    exit 0
fi