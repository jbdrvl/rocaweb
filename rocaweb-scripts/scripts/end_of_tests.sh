#!/bin/bash

# author: github.com/jbdrvl
# date: July 2017

### This script stops the RoCaWeb Docker images and launches docker-compose down

cd $1 # path to Docker folder

sudo docker-compose down

echo "[INFO] if an error occurs during the compose down: sudo docker rm -f \$(sudo docker ps -a -q)"

