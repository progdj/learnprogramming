#!/bin/bash

# Start apache and tail the error log in the background
source /etc/apache2/envvars
tail -F /var/log/apache2/error.log | cut -d" " -f 11- | grep PHP >&2 &
exec apache2 -D FOREGROUND
