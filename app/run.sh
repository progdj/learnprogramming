#!/bin/bash

echo AMAK Data Container initialized

AMAK_DIR_PROJECT=/var/www/amak-frontend
AMAK_DIR_HTML2PDF=$AMAK_DIR_PROJECT/protected/vendor/html2pdf/html2pdf

CMS_DIR_PROJECT=/var/www/amak-cms
CMS_DIR_HTML2PDF=$CMS_DIR_PROJECT/protected/vendor/html2pdf/html2pdf

# Check if project files are deployed
if [ -d AMAK_DIR_PROJECT ]; then

    mkdir -p $AMAK_DIR_PROJECT/protected/runtime/
    chmod 777 -R $AMAK_DIR_PROJECT/protected/runtime/
    
    mkdir -p $AMAK_DIR_PROJECT/assets/
    chmod 777 -R $AMAK_DIR_PROJECT/assets/
    
    mkdir -p $AMAK_DIR_HTML2PDF/cache/
    chmod 777 -R $AMAK_DIR_HTML2PDF/cache/
fi


if [ -d $CMS_DIR_PROJECT ]; then
    
    mkdir -p $CMS_DIR_PROJECT/protected/runtime/
    chmod 777 -R $CMS_DIR_PROJECT/protected/runtime/
    
    mkdir -p $CMS_DIR_PROJECT/assets/
    chmod 777 -R $CMS_DIR_PROJECT/assets/
    
    mkdir -p $CMS_DIR_HTML2PDF/cache/
    chmod 777 -R $CMS_DIR_HTML2PDF/cache/
fi
