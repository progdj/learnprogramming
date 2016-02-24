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
    
    chmod 777 -R $AMAK_DIR_HTML2PDF/cache/
    
    mkdir -p $AMAK_DIR_PROJECT/protected/runtime/
    chmod 777 -R $AMAK_DIR_PROJECT/protected/runtime/

    mkdir -p $AMAK_DIR_PROJECT/assets/
    chmod 777 -R $AMAK_DIR_PROJECT/assets/
    
    echo Done.
fi


if [ -d $CMS_DIR_CONFIG ]; then
    echo Copying project configuration files for cms...

    cp /db_local.php $CMS_DIR_CONFIG
    cp /paths.php $CMS_DIR_CONFIG
    
    mkdir -p $CMS_DIR_PROJECT/protected/runtime/
    chmod 777 -R $CMS_DIR_PROJECT/protected/runtime/
    
    mkdir -p $CMS_DIR_PROJECT/assets/
    chmod 777 -R $CMS_DIR_PROJECT/assets/
    
    echo Done.
fi
