#!/bin/bash

# Setup Config
/scripts/config.sh /amak-config /amak-data

# amak docker development bootstrap
AMAK_FRONTEND_ACTIVATED="no"
AMAK_PORTAL_ACTIVATED="no"
AMAK_CMS_ACTIVATED="no"

# package frontend
echo -e "#####\n##### FRONTEND\n#####\n"
if [ -d /var/www/amak-frontend ]; then
    # apply configuration
    cd /var/www/amak-frontend;
    vendor/bin/phing config;

    # prepare logging
    sudo -u www-data -g www-data touch /var/www/amak-frontend/protected/runtime/php-error.log
    sudo -u www-data -g www-data touch /var/www/amak-frontend/protected/runtime/error.log

    vhostprecheck=`php yiic apachesetup check --filter=frontend`
    if [ $? -eq 0  ]; then
        echo -e "$vhostprecheck";
        # perform migrations
        php yiic migrate --interactive=0
        # prepare dynamic vhosts for amak-frontend
        frontendvhosts=`/scripts/package-macro-vhosts.sh frontend /var/www/amak-frontend /amak-config .production`;
        echo -e "$frontendvhosts" > /etc/apache2/sites-available/01-amak-frontend.conf;
        echo -e $frontendvhosts;
        a2ensite 01-amak-frontend;
        a2ensite 03-amak-assets
        echo -e "\n127.0.0.1 assets.amak-server.local" >> /etc/hosts
        AMAK_FRONTEND_ACTIVATED="yes"
    else
        >&2 echo "WARN: Package amak-frontend is not yet ready to use please check your setup!";
        >&2 echo "WARN: Typical Fails: db still empty, invalid config.properties in amak-frontend...";
        >&2 echo "WARN: Error message follows...";
        >&2 echo -e "$vhostprecheck"
    fi;
else
    a2dissite 01-amak-frontend;
    a2dissite 03-amak-assets
    echo "INFO: Package amak-frontend is not existing, will not perform automatic configuration.";
fi

echo -e "#####\n##### CMS\n#####\n"

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
        AMAK_CMS_ACTIVATED="yes"
else
    echo "Package amak-cms is not existing, will not perform automatic configuration.";
    a2dissite 02-amak-cms
fi


# package portal
if [ -d /var/www/amak-portal ]; then
    # apply configuration
    cd /var/www/amak-portal;
    vendor/bin/phing config;

    #prepare logging
    sudo -u www-data -g www-data touch /var/www/amak-portal/protected/runtime/php-error.log
    sudo -u www-data -g www-data touch /var/www/amak-portal/protected/runtime/error.log

    vhostprecheck=`php yiic apachesetup check --filter=portal`
    if [ $? -eq 0  ]; then
        echo -e "$vhostprecheck";
        # perform migrations
        php yiic migrate --interactive=0
        # prepare dynamic vhosts for amak-portal
        portalvhosts=`/scripts/package-macro-vhosts.sh portal /var/www/amak-portal /amak-config .production`;
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
    a2dissite 04-amak-portal
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
    tail -F -n 0 /var/log/apache2/amak-assets-error.log 2>/dev/null >&2 &
    for((i=20; i>0; i--))
    do
       tail -F -n 0 /var/log/apache2/amak-frontend-$i-error.log 2>/dev/null >&2 &
    done
fi;

if [ -d /var/www/amak-portal ]; then
    tail -F -n 0 /var/www/amak-portal/protected/runtime/php-error.log >&2 &
    tail -F -n 0 /var/www/amak-portal/protected/runtime/error.log >&2 &
    for((i=20; i>0; i--))
    do
       tail -F -n 0 /var/log/apache2/amak-portal-$i-error.log 2>/dev/null >&2 &
    done
fi;

if [ -d /var/www/amak-cms ]; then
    tail -F -n 0 /var/www/amak-cms/protected/runtime/php-error.log >&2 &
    tail -F -n 0 /var/www/amak-cms/protected/runtime/error.log >&2 &
    tail -F -n 0 /var/log/apache2/amak-cms-error.log 2>/dev/null >&2 &
fi;

exec apache2 -D FOREGROUND
