#!/bin/bash

# Start apache and tail the logs in the background
source /etc/apache2/envvars
tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND
