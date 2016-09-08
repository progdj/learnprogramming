#!/usr/bin/env bash

function ipfor() {
  ping -c 1 $1 | grep -Eo -m 1 '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}';
}

AMAK_HTTP_IP=`ipfor "http"`

#Adbooker Docker localq
echo -e "\n${AMAK_HTTP_IP} cdn.vrs.local" >> /etc/hosts
# AdBooker-CMS
echo -e "\n${AMAK_HTTP_IP} cms.vrs.local" >> /etc/hosts
# AdBooker
echo -e "\n${AMAK_HTTP_IP} vrsmedia.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} schwaebische-post.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} gmuender-tagespost.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} main-netz.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} merkur-online.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} gea.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} anzeigen.general-anzeiger-bonn.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} haller-kreisblatt.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} dagblad.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} stimme.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} echonews.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} hna.anzeigen-aufgabe.de.local" >> /etc/hosts
echo -e "\n${AMAK_HTTP_IP} rhz.anzeigen-aufgabe.de.local" >> /etc/hosts

for ((i=1; i<50; i++));
do
    echo -e "\n${AMAK_HTTP_IP} frontend-$i" >> /etc/hosts
    echo -e "\n${AMAK_HTTP_IP} portal-$i" >> /etc/hosts
done

