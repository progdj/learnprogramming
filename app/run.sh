#!/bin/bash

echo AMAK Data Container initialized

DIR_CONFIG="/var/www/amak-frontend/protected/config"

# Check if project files are deployed
if [ -d $DIR_CONFIG ]; then
    echo Copying project configuration files...

    cp /db_local.php $DIR_CONFIG
    cp /paths.php $DIR_CONFIG

    echo Done.
else
    >&2 echo ERROR: No project files found!
    >&2 echo NOTICE: Copying default page with further instructions

    mkdir /var/www/amak-frontend/img > /dev/null
    cp /default/* /var/www/amak-frontend
    cp /default/img/* /var/www/amak-frontend/img
fi