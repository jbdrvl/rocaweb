#!/bin/bash

# author: github.com/jbdrvl
# date: July 2017, updated August 2017

### VARIABLES


JMETER_LOCATION=$3
WEBSITE_TITLE=$4
PDML_FILE=$1
MAIN_LOCATION=$5
ALGO_LIST="$(cat $MAIN_LOCATION/algo_list.txt)" #$2 

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "${PDML_FILE: -5}" == ".pdml" ]; then
	echo -e "${YELLOW}[INFO]${NC} RULES PRODUCTION for PDML file $PDML_FILE"
else
	echo -e "${RED}[ERROR]${NC} There was an error when passing on the PDML file from one script to the other."
	exit
fi


### MAIN
### LAUNCHES JMETER NON GUI to clusterize data from PDML
$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t "$MAIN_LOCATION/scripts/jmeter-scripts/rules_production_jmeter_CLUSTERIZE.jmx" -JPDML_file=$PDML_FILE -Jlocation=$MAIN_LOCATION

DATETIME="$(date +%Y-%m-%d_%Hh%M)"
mkdir $MAIN_LOCATION/RULES/$DATETIME

### USES PYTHON TO GET ALL END-NODES into one CSV file
python3.4 $MAIN_LOCATION/scripts/python-scripts/findAllNodes.py $MAIN_LOCATION/results_jmeter1.octet-stream $MAIN_LOCATION/nodes.csv

echo -e "${YELLOW}[SUCCESS]${NC} data was successfully clusterized and is now ready to be sent through RoCaWeb to create rules."

for i in ${ALGO_LIST[*]}
do
	echo -e "${YELLOW}ALGORITHM: $i${NC}"
	$MAIN_LOCATION/scripts/rules_production_all_indiv.sh $MAIN_LOCATION $i $JMETER_LOCATION $WEBSITE_TITLE $MAIN_LOCATION/RULES/$DATETIME
done

# removes temporary files
rm $MAIN_LOCATION/nodes.csv
rm $MAIN_LOCATION/results_jmeter1.octet-stream
echo -e "${GREEN}[SUCCESS]${NC} all .conf rules should be ready and stored in $MAIN_LOCATION/RULES/$DATETIME"

