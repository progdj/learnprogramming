#!/bin/bash
echo "Config /etc/hosts"
perl /hostconfig/host_config.pl

while read line; do
  echo -e $line >> /etc/hosts
done </hostcopnfig/hosts.tmp