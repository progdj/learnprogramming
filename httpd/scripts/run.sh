#!/bin/bash

# amak docker development bootstrap

# package frontend
if [ -d /var/www/amak-frontend ]; then
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
    else
        >&2 echo "Package amak-frontend is not yet ready to use please check your setup! Error was: ";
        >&2 echo -e "$vhostprecheck"
    fi;
else
    echo "Package amak-frontend is not existing, will not perform automatic configuration.";
fi

# package cms
if [ -d /var/www/amak-cms ]; then

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
else
    echo "Package amak-cms is not existing, will not perform automatic configuration.";
fi

# amak assets
if [ -d /var/www/amak-frontend ]; then
    a2ensite 03-amak-assets
fi;

# package portal
if [ -d /var/www/amak-portal ]; then

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
    else
        >&2 echo "Package amak-portal is not yet ready to use please check your setup! Error was: ";
        >&2 echo -e "$vhostprecheck"
    fi;


else
    echo "Package amak-portal is not existing, will not perform automatic configuration.";
fi

# Start apache and tail the error log in the background
source /etc/apache2/envvars
rm -f /var/run/apache2/apache2.pid

touch /var/log/apache2/error.log;
tail -F /var/log/apache2/error.log >&2 &

if [ -d /var/www/amak-frontend ]; then
    tail -F /var/www/amak-frontend/protected/runtime/php-error.log >&2 &
    tail -F /var/www/amak-frontend/protected/runtime/error.log >&2 &
fi;

if [ -d /var/www/amak-portal ]; then
    tail -F /var/www/amak-portal/protected/runtime/php-error.log >&2 &
    tail -F /var/www/amak-portal/protected/runtime/error.log >&2 &
fi;

if [ -d /var/www/amak-cms ]; then
    tail -F /var/www/amak-cms/protected/runtime/php-error.log >&2 &
    tail -F /var/www/amak-cms/protected/runtime/error.log >&2 &
fi;


exec apache2 -D FOREGROUND
