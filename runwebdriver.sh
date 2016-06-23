#!/bin/bash
cd webdriver
eval $(docker-machine env)
docker-compose up
