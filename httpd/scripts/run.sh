#!/bin/bash

# amak docker development bootstrap
AMAK_FRONTEND_ACTIVATED="no"
AMAK_PORTAL_ACTIVATED="no"
AMAK_CMS_ACTIVATED="no"

# package frontend
echo -e "#####\n##### FRONTEND\n#####\n"
if [ -d /var/www/amak-frontend ]; then
    if [ -f /var/www/amak-frontend/vendor/bin/phing ]; then
        #runtime folders
        mkdir -p /var/www/amak-frontend/assets
        chmod -R 777 /var/www/amak-frontend/assets
        mkdir -p /var/www/amak-frontend/upload
        chmod -R 777 /var/www/amak-frontend/upload
        mkdir -p /var/www/amak-frontend/protected/runtime
        chmod -R 777 /var/www/amak-frontend/protected/runtime
        mkdir -p /var/www/amak-frontend/protected/vendor/html2pdf/html2Pdf/cache
        chmod -R 777 /var/www/amak-frontend/protected/vendor/html2pdf/html2Pdf/cache
        mkdir -p /var/www/amak-frontend/protected/vendor/html2pdf/html2Pdf/temp
        chmod -R 777 /var/www/amak-frontend/protected/vendor/html2pdf/html2Pdf/temp
        mkdir -p /var/www/amak-frontend/protected/vendor/html2pdf/html2Pdf/out
        chmod -R 777 /var/www/amak-frontend/protected/vendor/html2pdf/html2Pdf/out

        # apply configuration
        cd /var/www/amak-frontend;
        vendor/bin/phing config;

        # prepare logging
        sudo -u www-data -g www-data touch /var/www/amak-frontend/protected/runtime/php-error.log
        sudo -u www-data -g www-data touch /var/www/amak-frontend/protected/runtime/error.log

        vhostprecheck=`php yiic apachesetup check --filter=frontend`
        if [ $? -eq 0  ]; then
            echo -e "$vhostprecheck";
            # prepare dynamic vhosts for amak-frontend
            frontendvhosts=`/scripts/package-macro-vhosts.sh frontend /var/www/amak-frontend /config .local`;
            echo -e "$frontendvhosts" > /etc/apache2/sites-available/01-amak-frontend.conf;
            echo -e $frontendvhosts;
            a2ensite 01-amak-frontend;
            a2ensite 03-amak-assets
            AMAK_FRONTEND_ACTIVATED="yes"
        else
            >&2 echo "WARN: Package amak-frontend is not yet ready to use please check your setup!";
            >&2 echo "WARN: Typical Fails: db still empty, invalid config.properties in amak-frontend...";
            >&2 echo "WARN: Error message follows...";
            >&2 echo -e "$vhostprecheck"
        fi;
    else
        >&2 echo "WARN: Package amak-frontend is not yet ready to use please run composer update!";
    fi;
else
    echo "INFO: Package amak-frontend is not existing, will not perform automatic configuration.";
fi

echo -e "#####\n##### CMS\n#####\n"

# package cms
if [ -d /var/www/amak-cms ]; then
    if [ -f /var/www/amak-cms/vendor/bin/phing ]; then
        #runtime folders
        mkdir -p /var/www/amak-cms/assets
        chmod -R 777 /var/www/amak-cms/assets
        mkdir -p /var/www/amak-cms/upload
        chmod -R 777 /var/www/amak-cms/upload
        mkdir -p /var/www/amak-cms/protected/runtime
        chmod -R 777 /var/www/amak-cms/protected/runtime
        mkdir -p /var/www/amak-cms/protected/vendor/html2pdf/html2Pdf/cache
        chmod -R 777 /var/www/amak-cms/protected/vendor/html2pdf/html2Pdf/cache
        mkdir -p /var/www/amak-cms/protected/vendor/html2pdf/html2Pdf/temp
        chmod -R 777 /var/www/amak-cms/protected/vendor/html2pdf/html2Pdf/temp
        mkdir -p /var/www/amak-cms/protected/vendor/html2pdf/html2Pdf/out
        chmod -R 777 /var/www/amak-cms/protected/vendor/html2pdf/html2Pdf/out

        # apply configuration
        cd /var/www/amak-cms;
        vendor/bin/phing config;

        #prepare logging
        sudo -u www-data -g www-data touch /var/www/amak-cms/protected/runtime/php-error.log
        sudo -u www-data -g www-data touch /var/www/amak-cms/protected/runtime/error.log

        a2ensite 02-amak-cms
        AMAK_CMS_ACTIVATED="yes"
    else
        >&2 echo "WARN: Package amak-cms is not yet ready to use please run composer update!";
    fi;
else
    echo "INFO: Package amak-cms is not existing, will not perform automatic configuration.";
fi;


echo -e "#####\n##### PORTAL\n#####\n"

# package portal
if [ -d /var/www/amak-portal ]; then
    if [ -f /var/www/amak-portal/vendor/bin/phing ]; then
        #runtime folders
        mkdir -p /var/www/amak-portal/assets
        chmod -R 777 /var/www/amak-portal/assets
        mkdir -p /var/www/amak-portal/protected/runtime
        chmod -R 777 /var/www/amak-portal/protected/runtime

        # apply configuration
        cd /var/www/amak-portal;
        vendor/bin/phing config;

        #prepare logging
        sudo -u www-data -g www-data touch /var/www/amak-portal/protected/runtime/php-error.log
        sudo -u www-data -g www-data touch /var/www/amak-portal/protected/runtime/error.log

        vhostprecheck=`php yiic apachesetup check --filter=portal`
        if [ $? -eq 0  ]; then
            echo -e "$vhostprecheck";
            # prepare dynamic vhosts for amak-portal
            portalvhosts=`/scripts/package-macro-vhosts.sh portal /var/www/amak-portal /config .local`;
            echo -e "$portalvhosts" > /etc/apache2/sites-available/04-amak-portal.conf
            echo -e $portalvhosts
            a2ensite 04-amak-portal
            AMAK_PORTAL_ACTIVATED="yes"
        else
            >&2 echo "WARN: Package amak-portal is not yet ready to use please check your setup!";
            >&2 echo "WARN: Typical Fails: db still empty, invalid config.properties in amak-portal...";
            >&2 echo "WARN: Error message follows...";
            >&2 echo -e "$vhostprecheck"
        fi;
    else
        >&2 echo "WARN: Package amak-portal is not yet ready to use please run composer update!";
    fi;
else
    echo "INFO: Package amak-portal is not existing, will not perform automatic configuration.";
fi;


echo "########################################################################################"
echo "########################################################################################"
echo "Packages Active: FRONTEND $AMAK_FRONTEND_ACTIVATED / CMS $AMAK_CMS_ACTIVATED / PORTAL $AMAK_PORTAL_ACTIVATED"
echo "########################################################################################"
echo "########################################################################################"
# Start apache and tail the error log in the background
source /etc/apache2/envvars
rm -f /var/run/apache2/apache2.pid

touch /var/log/apache2/error.log;
tail -F -n 0 /var/log/apache2/error.log >&2 &

if [ -d /var/www/amak-frontend ]; then
    tail -F -n 0 /var/www/amak-frontend/protected/runtime/php-error.log >&2 &
    tail -F -n 0 /var/www/amak-frontend/protected/runtime/error.log >&2 &
fi;

if [ -d /var/www/amak-portal ]; then
    tail -F -n 0 /var/www/amak-portal/protected/runtime/php-error.log >&2 &
    tail -F -n 0 /var/www/amak-portal/protected/runtime/error.log >&2 &
fi;

if [ -d /var/www/amak-cms ]; then
    tail -F -n 0 /var/www/amak-cms/protected/runtime/php-error.log >&2 &
    tail -F -n 0 /var/www/amak-cms/protected/runtime/error.log >&2 &
fi;


exec apache2 -D FOREGROUND
