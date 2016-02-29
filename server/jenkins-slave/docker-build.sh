#!/bin/bash

#
# Jenkins Deployment Entry Script
#

# clean used packages first
rm -R -f /home/jenkins/docker/packages/*.tar.gz

# copy current packages
mv /home/jenkins/packages/*.tar.gz /home/jenkins/docker/packages/

cd /home/jenkins/docker


docker build -t amak-develop-base ./
docker stop amak-develop
docker rm amak-develop
docker run -d -v /mnt/data/BETA/amak-data/frontend:/amak-data -v /home/jenkins/develop:/amak-config -p 0.0.0.0:8080:80 --name=amak-develop amak-develop-base