#!/bin/bash

# Perform Configuration Tasks during Container Start.
# Expects parameter
# 1 path to package configurations
# 2 path to shared nfs amak frontend/cms data directory
# 3 path to shared nfs amak portal data directory

configPath=$1
amakDataPath=$2
portalDataPath=$3

if [ -d /var/www/amak-frontend ]; then
  cp $configPath/config.properties /var/www/amak-frontend/
  cd /var/www/amak-frontend/
  ./vendor/bin/phing config
  /scripts/mount.sh /var/www/amak-frontend/ $amakDataPath
fi;

if [ -d /var/www/amak-cms ]; then
  cp $configPath/config.properties /var/www/amak-cms/
  cd /var/www/amak-cms/
  ./vendor/bin/phing config
  /scripts/mount.sh /var/www/amak-cms/ $amakDataPath
fi;


if [ -d /var/www/amak-portal ]; then
  cp $configPath/config.properties /var/www/amak-portal/
  cd /var/www/amak-portal/
  ./vendor/bin/phing config
  /scripts/mount.sh /var/www/amak-portal $portalDataPath
fi;