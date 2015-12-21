#!/bin/bash

# Start apache and tail the logs in the background
source /etc/apache2/envvars
touch /var/log/apache2/php.log
tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND
