#!/bin/bash

# author: github.com/jbdrvl
# date: July 2017, updated August 2017

### VARIABLES
PATH_TO_DOCKER_FOLDER=$1
JMETER_LOCATION=$2
MAIN_LOCATION=$3

### This script launches the RoCaWeb Docker images and JMeter to start testing

cd $PATH_TO_DOCKER_FOLDER

sudo service apache2 stop
sudo service nginx stop

sudo docker-compose up &

gnome-terminal -e "$MAIN_LOCATION/scripts/launch_jmeter.sh $JMETER_LOCATION $MAIN_LOCATION"
#gnome-terminal -e "tail -f ./var/log/apache2/error.log"

