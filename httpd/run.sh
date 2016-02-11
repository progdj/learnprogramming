#!/bin/bash

# Start apache and tail the error log in the background
source /etc/apache2/envvars
rm -f /var/run/apache2/apache2.pid
tail -F /var/log/apache2/error.log | cut -d" " -f 11- | grep PHP >&2 &
exec apache2 -D FOREGROUND
