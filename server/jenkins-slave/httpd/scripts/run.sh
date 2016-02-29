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
    # prepare dynamic vhosts for amak-frontend
    frontendvhosts=`/scripts/package-macro-vhosts.sh frontend /var/www/amak-frontend /amak-config .production`
    echo "$frontendvhosts" > /etc/apache2/sites-available/01-amak-frontend.conf
    a2ensite 01-amak-frontend
else
    echo "Package amak-frontend is not existing, will not perform automatic configuration.";
    a2dissite 01-amak-frontend
fi

# package cms
if [ -d /var/www/amak-source ]; then
    # apply configuration
    cd /var/www/amak-cms;
    vendor/bin/phing config;
    a2ensite 02-amak-cms
else
    echo "Package amak-cms is not existing, will not perform automatic configuration.";
    a2dissite 02-amak-cms
fi

# amak source
if [ -d /var/www/amak-source ]; then
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
    # prepare dynamic vhosts for amak-portal
    portalvhosts=`/scripts/package-macro-vhosts.sh portal /var/www/amak-portal /amak-config .production`;
    echo "$portalvhosts" > /etc/apache2/sites-available/05-amak-portal.conf
    a2ensite 05-amak-portal
else
    echo "Package amak-portal is not existing, will not perform automatic configuration.";
    a2dissite 05-amak-portal
fi

# Start apache and tail the error log in the background
source /etc/apache2/envvars
rm -f /var/run/apache2/apache2.pid
tail -F /var/log/apache2/error.log | cut -d" " -f 11- | grep PHP >&2 &
exec apache2 -D FOREGROUND