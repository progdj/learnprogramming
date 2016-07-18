#!/usr/bin/env bash

function ipfor() {
  ping -c 1 $1 | grep -Eo -m 1 '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}';
}

AMAK_HTTP_IP=`ipfor "http"`

for ((i=1; i<50; i++));
do
    echo -e "\n${AMAK_HTTP_IP} frontend-$i" >> /etc/hosts
    echo -e "\n${AMAK_HTTP_IP} portal-$i" >> /etc/hosts
done