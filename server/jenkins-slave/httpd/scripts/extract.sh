#!/bin/bash

# Extracts all detected packages

if [ -f /amak-packages/amak-frontend.tar.gz ]; then
  tar -xpxzf /amak-packages/amak-frontend.tar.gz -C /var/www/
fi;

if [ -f /amak-packages/amak-source.tar.gz ]; then
  tar -xpxzf /amak-packages/amak-source.tar.gz -C /var/www/
fi;

if [ -f /amak-packages/amak-cms.tar.gz ]; then
  tar -xpxzf /amak-packages/amak-cms.tar.gz -C /var/www/
fi;

if [ -f /amak-packages/amak-portal.tar.gz ]; then
  tar -xpxzf /amak-packages/amak-portal.tar.gz -C /var/www/
fi;


rm -R -f /amak-packages/amak*