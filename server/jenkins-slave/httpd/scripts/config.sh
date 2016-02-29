#!/bin/bash

# Perform Configuration Tasks during Container Start.
# Expects parameter #1 path to package configurations #2 path to shared nfs data directory

configPath=$1
sharedDataPath=$2

if [ -d /var/www/amak-frontend ]; then
  cp $configPath/config.properties /var/www/amak-frontend/
  cd /var/www/amak-frontend/
  ./vendor/bin/phing config
  /scripts/mount.sh /var/www/amak-frontend/ $sharedDataPath
fi;

if [ -d /var/www/amak-cms ]; then
  cp $configPath/config.properties /var/www/amak-cms/
  cd /var/www/amak-cms/
  ./vendor/bin/phing config
  /scripts/mount.sh /var/www/amak-cms/ $sharedDataPath
fi;


if [ -d /var/www/amak-portal ]; then
  cp $configPath/config.properties /var/www/amak-portal/
  cd /var/www/amak-portal/
  ./vendor/bin/phing config
  /scripts/mount.sh /var/www/amak-portal $sharedDataPath
fi;