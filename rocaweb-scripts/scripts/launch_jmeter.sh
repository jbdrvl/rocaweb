#!/bin/bash

# author: github.com/jbdrvl
# date: July 2017, updated August 2017

### This script launches JMeter after installing Hackazon and signing up user John Smith

### VARIABLES
JMETER_LOCATION=$1
MAIN_LOCATION=$2
TEST_PLANS_LOCATION=$MAIN_LOCATION/scripts/jmeter-scripts

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# wait for Hackazon to be up and running
echo -e "${YELLOW}[INFO]${NC} waiting for Hackazon to be up and running..."
RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost)
while [ $RESPONSE != 302 ]; do
	sleep 1
	RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost)
done
echo -e "${GREEN}[SUCCESS]${NC} Hackazon looks ready to be installed: http://localhost/install."

### LAUNCHES JMETER NON GUI - installation then signing up John Smith as test user
$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t "$TEST_PLANS_LOCATION/launch_installation_hackazon.jmx"
$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t "$TEST_PLANS_LOCATION/launch_john_smith_signs_up.jmx"
echo -e "${YELLOW}[INFO]${NC} It is expected that ONE error will occur during the john_smith_signs_up Test Plan. This is due to an error with Hackazon and has no impact on the rest of the tests."
echo -e "${YELLOW}[INFO]${NC} If there are more errors, it may be because the firewall rules are blocking some of the information John Smith is trying to send for his register form."




