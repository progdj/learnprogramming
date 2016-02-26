#!/bin/bash

# amak docker development bootstrap

# package frontend
if [ -d /var/www/amak-frontend ]; then
    # apply configuration
    cd /var/www/amak-frontend;
    vendor/bin/phing config;
    # prepare dynamic vhosts for amak-frontend
    frontendvhosts=`/scripts/package-macro-vhosts.sh frontend /var/www/amak-frontend /config .local`
    if [ $? -eq 0 ]; then
        echo "$frontendvhosts" > /etc/apache2/sites-enabled/01-amak-frontend.conf
    else
        echo "$frontendvhosts";
    fi
else
    echo "Package amak-frontend is not existing, will not perform automatic configuration.";
fi

# package portal
if [ -d /var/www/amak-portal ]; then
    # apply configuration
    cd /var/www/amak-portal;
    vendor/bin/phing config;
    # prepare dynamic vhosts for amak-portal
    portalvhosts=`/scripts/package-macro-vhosts.sh portal /var/www/amak-portal /config .local`;
    if [ $? -eq 0 ]; then
        echo "$portalvhosts" > /etc/apache2/sites-enabled/05-amak-portal.conf
    else
        echo "$portalvhosts";
    fi
else
    echo "Package amak-portal is not existing, will not perform automatic configuration.";
fi

# package cms
if [ -d /var/www/amak-cms ]; then
    # apply configuration
    cd /var/www/amak-cms;
    vendor/bin/phing config;
else
    echo "Package amak-cms is not existing, will not perform automatic configuration.";
fi

# Start apache and tail the error log in the background
source /etc/apache2/envvars
rm -f /var/run/apache2/apache2.pid
tail -F /var/log/apache2/error.log | cut -d" " -f 11- | grep PHP >&2 &
exec apache2 -D FOREGROUND
