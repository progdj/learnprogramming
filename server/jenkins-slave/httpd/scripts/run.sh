#!/bin/bash

# Setup Config
/scripts/config.sh /amak-config /amak-data

# Updates
#/update.sh

# package frontend
if [ -d /var/www/amak-frontend ]; then
    # apply configuration
    cd /var/www/amak-frontend;
    vendor/bin/phing config;

    # prepare logging
    sudo -u www-data -g www-data touch /var/www/amak-frontend/protected/runtime/php-error.log
    sudo -u www-data -g www-data touch /var/www/amak-frontend/protected/runtime/error.log

    # prepare dynamic vhosts for amak-frontend
    frontendvhosts=`/scripts/package-macro-vhosts.sh frontend /var/www/amak-frontend /amak-config .production`
    echo -e "$frontendvhosts" > /etc/apache2/sites-available/01-amak-frontend.conf
    a2ensite 01-amak-frontend
else
    echo "Package amak-frontend is not existing, will not perform automatic configuration.";
    a2dissite 01-amak-frontend
fi

# package cms
if [ -d /var/www/amak-cms ]; then
    # apply configuration
    cd /var/www/amak-cms;
    vendor/bin/phing config;

    #prepare logging
    sudo -u www-data -g www-data touch /var/www/amak-cms/protected/runtime/php-error.log
    sudo -u www-data -g www-data touch /var/www/amak-cms/protected/runtime/error.log

    if [ -f /amak-config/cms.domains.properties ]; then
        cmsAlias=`cat /amak-config/cms.domains.properties`
        echo -n "ServerAlias $cmsAlias"  > /etc/apache2/cms-domains.conf
    fi;
    a2ensite 02-amak-cms
else
    echo "Package amak-cms is not existing, will not perform automatic configuration.";
    a2dissite 02-amak-cms
fi

# amak source
if [ -d /var/www/amak-source ]; then
    if [ -f /amak-config/cdn.domains.properties ]; then
        cdnAlias=`cat /amak-config/cdn.domains.properties`
        echo -n "ServerAlias $cdnAlias"  > /etc/apache2/cdn-domains.conf
    fi;
    a2ensite 03-amak-assets
    a2ensite 04-amak-cdn
else
    a2dissite 03-amak-assets
    a2dissite 04-amak-cdn
fi;

# package portal
if [ -d /var/www/amak-portal ]; then
    # apply configuration
    cd /var/www/amak-portal;
    vendor/bin/phing config;

    #prepare logging
    sudo -u www-data -g www-data touch /var/www/amak-portal/protected/runtime/php-error.log
    sudo -u www-data -g www-data touch /var/www/amak-portal/protected/runtime/error.log

    # prepare dynamic vhosts for amak-portal
    portalvhosts=`/scripts/package-macro-vhosts.sh portal /var/www/amak-portal /amak-config .production`;
    echo -e "$portalvhosts" > /etc/apache2/sites-available/05-amak-portal.conf
    a2ensite 05-amak-portal
else
    echo "Package amak-portal is not existing, will not perform automatic configuration.";
    a2dissite 05-amak-portal
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