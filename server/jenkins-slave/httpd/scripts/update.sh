#!/bin/bash


# Perform Yii migrations if needed
cd /var/ww/amak-frontend/
php yiic migrate --interactive=0

cd /var/ww/amak-cms/
php yiic migrate --interactive=0