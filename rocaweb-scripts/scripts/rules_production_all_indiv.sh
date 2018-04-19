#!/bin/bash

# author: github.com/jbdrvl
# date: July 2017

### THIS SCRIPT IS CALLED BY rules_production_all.sh AND IS NOT SUPPOSED TO BE EXECUTED INDEPENDENTLY.

# CHECK FOR PARAMETERS

MAIN_LOCATION=$1

case "$2" in
	amaa | attributelength | acd | qualitycontrol | regexlearner | boxplot | kolmogorov | crossvalidation )	ALGO="$2"
												;;
	* )											ALGO="amaa"
												;;
esac

JMETER_LOCATION=$3

WEBSITE_TITLE=$4

FINAL_LOCATION=$5

### MAIN

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $ALGO == "crossvalidation" ]; then
	echo -e "${YELLOW}[INFO]${NC} CrossValidation may take a while."
fi

# JMETER RUNNING THE ALGO TO PRODUCE THE RULES and save them all independently into txt files
DATETIME="$(date +%Y-%m-%d_%Hh%M)"
mkdir $MAIN_LOCATION/$ALGO
mkdir $MAIN_LOCATION/$ALGO/$DATETIME

# creating rules with given algorithm
$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t "$MAIN_LOCATION/scripts/jmeter-scripts/rules_production_jmeter_RUN.jmx" -Jcsv_file=$MAIN_LOCATION/nodes.csv -Jalgo=$ALGO -Jlocation=$MAIN_LOCATION/$ALGO/$DATETIME

# getting job numbers to know which rules to import
END_JSON=$(python3.4 $MAIN_LOCATION/scripts/python-scripts/parseJson.py $MAIN_LOCATION/$ALGO/$DATETIME/json_file1.json)
LENGTH_CSV=$(cat $MAIN_LOCATION/nodes.csv | wc -l)
START_VALUE=$(($END_JSON-$LENGTH_CSV+1))
echo $START_VALUE

# importing the right rules 
$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t "$MAIN_LOCATION/scripts/jmeter-scripts/rules_production_jmeter_IMPORT.jmx" -Jcsv_file=$MAIN_LOCATION/nodes.csv -Jlocation=$MAIN_LOCATION/$ALGO/$DATETIME -Jstart_value=$START_VALUE

echo -e "${YELLOW}[INFO]${NC} rules were successfully created and imported."

# MERGE ALL RULES into one big .csv file
echo $(($(ls -l $MAIN_LOCATION/$ALGO/$DATETIME | wc -l)-2))
NUM_FILES=$(($(ls -l $MAIN_LOCATION/$ALGO/$DATETIME | wc -l)-2))
python3.4 $MAIN_LOCATION/scripts/python-scripts/mergeRules.py $MAIN_LOCATION/$ALGO/$DATETIME $NUM_FILES $MAIN_LOCATION/$ALGO/$WEBSITE_TITLE-$ALGO-$DATETIME.csv $START_VALUE

# CONVERTS .csv in .conf
mkdir $MAIN_LOCATION/RULES
cp $MAIN_LOCATION/$ALGO/$WEBSITE_TITLE-$ALGO-$DATETIME.csv $FINAL_LOCATION/$WEBSITE_TITLE-$ALGO-$DATETIME.conf

# removing temporary folder
rm -r $MAIN_LOCATION/$ALGO

echo -e "${GREEN}[INFO]${NC} .conf rule file is ready for use in ${GREEN}$FINAL_LOCATION${NC} for algorithm: $ALGO."
