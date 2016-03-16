#!/bin/bash
docker-machine start
eval $(docker-machine env)
docker-compose up
