#!/bin/bash

echo AMAK Data Container initialized

AMAK_DIR_PROJECT=/var/www/amak-frontend
AMAK_DIR_CONFIG=$AMAK_DIR_PROJECT/protected/config
AMAK_DIR_HTML2PDF=$AMAK_DIR_PROJECT/protected/vendor/html2pdf/html2pdf

CMS_DIR_PROJECT=/var/www/amak-cms
CMS_DIR_CONFIG=$CMS_DIR_PROJECT/protected/config
# Check if project files are deployed
if [ -d $AMAK_DIR_CONFIG ]; then
    echo Copying project configuration files for amak...

    cp /db_local.php $AMAK_DIR_CONFIG
    cp /paths.php $AMAK_DIR_CONFIG
    cp /html2pdf.config.php $AMAK_DIR_HTML2PDF/config.inc.php
    
    mkdir $AMAK_DIR_PROJECT/protected/runtime/ -p
    chmod 777 -R $AMAK_DIR_PROJECT/protected/runtime/

    mkdir $AMAK_DIR_PROJECT/assets/ -p
    chmod 777 -R $AMAK_DIR_PROJECT/assets/
    
    echo Done.
else
    >&2 echo ERROR: No project files found!
    >&2 echo NOTICE: Copying default page with further instructions

    mkdir /var/www/amak-frontend/img > /dev/null
    cp /default/* /var/www/amak-frontend
    cp /default/img/* /var/www/amak-frontend/img
    
fi


if [ -d $CMS_DIR_CONFIG ]; then
    echo Copying project configuration files for cms...

    cp /db_local.php $CMS_DIR_CONFIG
    cp /paths.php $CMS_DIR_CONFIG
    
    mkdir $CMS_DIR_PROJECT/protected/runtime/ -p
    chmod 777 -R $CMS_DIR_PROJECT/protected/runtime/
    
    mkdir $CMS_DIR_PROJECT/assets/ -p
    chmod 777 -R $CMS_DIR_PROJECT/assets/
    
    echo Done.
fi
