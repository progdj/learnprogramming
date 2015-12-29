#!/bin/bash

echo AMAK Data Container initialized

DIR_PROJECT=/var/www/amak-frontend
DIR_CONFIG=$DIR_PROJECT/protected/config
DIR_HTML2PDF=$DIR_PROJECT/protected/vendor/html2pdf/html2pdf

# Check if project files are deployed
if [ -d $DIR_CONFIG ]; then
    echo Copying project configuration files...

    cp /db_local.php $DIR_CONFIG
    cp /paths.php $DIR_CONFIG
    cp /html2pdf.config.php $DIR_HTML2PDF/config.inc.php

    echo Done.
else
    >&2 echo ERROR: No project files found!
    >&2 echo NOTICE: Copying default page with further instructions

    mkdir /var/www/amak-frontend/img > /dev/null
    cp /default/* /var/www/amak-frontend
    cp /default/img/* /var/www/amak-frontend/img
fi