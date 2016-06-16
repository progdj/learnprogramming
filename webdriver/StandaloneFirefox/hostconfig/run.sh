#!/bin/bash
echo "Config /etc/hosts"
perl /hostconfig/host_config.pl

echo -e '\n#vrs.local' >> /etc/hosts

while read line; do
  echo -e $line >> /etc/hosts
done </hostcopnfig/hosts.tmp

# cat /hostconfig/hosts.tmp >> /etc/hosts