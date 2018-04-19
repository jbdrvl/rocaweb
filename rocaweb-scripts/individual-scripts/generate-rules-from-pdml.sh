#!/bin/bash

# author: github.com/jbdrvl
# date: July 2017, updated August 2017

RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

a=$(readlink -f "$0")
MAIN_LOCATION=${a:0:-47}
echo "[DEBUG] main location: $MAIN_LOCATION"

clear
help_function()
{
	local bold=$(tput bold)
	local normal=$(tput sgr0)
	echo "${bold}NAME"
	echo "		${normal}generate-rules-from-pdml.sh - generate ModSecurity rules from a PDML file, for all given algorithms."
	echo "${bold}SYNOPSIS"
	echo "		${normal}generate-rules-from-pdml.sh [OPTIONS] -h [PATH] -j ./path/to/jmeter [STRING] -w website_title [FILE] -f file.pdml"
	echo "${bold}DESCRIPTION"
	echo "		${normal}This script uses JMeter and Python scripts to generate ModSecurity for a given PDML file. Webui needs to be up and running before starting this script. Rules will be generated using the algorithms listed in algo_list.txt."
	echo "		${bold}-h, --help"
	echo "			${normal}displays this help menu"
	echo "		${bold}-j, --jmeter"
	echo "			${normal}path to the JMeter folder if JMeter is not implemented in Bash. Directory should contain ./apache-jmeter-3.2/ (with 3.2 being the version of JMeter - may be something else on your machine)."
	echo "		${bold}-f, --file"
	echo "			${normal}PDML file containing clean traffic to be used for generating rules."
	echo "		${bold}-w, --web"
	echo "			${normal}title of the website being tested. The title will be used to name rule and result files."
}

# GET PARAMETERS and check their type
while [ "$1" != "" ]; do
	case $1 in
		-h | --help )	clear
				help_function
				exit
				;;
		-j | --jmeter )	shift
				JMETER_LOCATION=$1
				if [[ -d "$JMETER_LOCATION" ]]; then
					if [ "${1:0:2}" == "./" ]; then
						JMETER_LOCATION="$(pwd)${1:1}"
						echo "[DEBUG] $JMETER_LOCATION"					
					fi					
					echo "[INFO] path to JMeter folder looks ok: $JMETER_LOCATION"
				else
					echo -e "${RED}[ERREUR]${NC} -f option expected a directory as input - path to JMeter folder"
					exit
				fi
				;;
		-f | --file )	shift
				if [ "${1: -5}" == ".pdml" ]; then
					PDML_FILE=$1
					if [ "${1:0:2}" == "./" ]; then
						PDML_FILE="$(pwd)${1:1}"
						echo "[DEBUG] $PDML_FILE"					
					fi
				else
					echo "${RED}[ERROR]${NC} Missing PDML file (.pdml) as -f parameter"
					exit
				fi
				;;
		-w | --web )	shift
				WEBSITE_TITLE=$1
				echo -e "${YELLOW}[INFO]${NC} Website title: $WEBSITE_TITLE"
				;;
		* ) 		echo -e "${RED}[ERROR]${NC} what is this: $1? This parameter was not expected."
				exit
				;;
	esac
	shift
done

ALGO_LIST="$(cat $MAIN_LOCATION/algo_list.txt)"

### MAIN
### LAUNCHES JMETER NON GUI to clusterize data from PDML
$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t "$MAIN_LOCATION/scripts/jmeter-scripts/rules_production_jmeter_CLUSTERIZE.jmx" -JPDML_file=$PDML_FILE -Jlocation=$MAIN_LOCATION

DATETIME="$(date +%Y-%m-%d_%Hh%M)"
mkdir $MAIN_LOCATION/RULES/$DATETIME

### USES PYTHON TO GET ALL END-NODES into one CSV file
python3.4 $MAIN_LOCATION/scripts/python-scripts/findAllNodes.py $MAIN_LOCATION/results_jmeter1.octet-stream $MAIN_LOCATION/nodes.csv

echo -e "${GREEN}[SUCCESS]${NC} data was successfully clusterized and is now ready to be sent through RoCaWeb to create rules."

for i in ${ALGO_LIST[*]}
do
	echo -e "${YELLOW}ALGORITHM: $i${NC}"
	$MAIN_LOCATION/scripts/rules_production_all_indiv.sh $MAIN_LOCATION $i $JMETER_LOCATION $WEBSITE_TITLE $MAIN_LOCATION/RULES/$DATETIME
done

rm $MAIN_LOCATION/nodes.csv
rm $MAIN_LOCATION/results_jmeter1.octet-stream
echo -e "${GREEN}[SUCCESS]${NC} all .conf rules should be ready and stored in $MAIN_LOCATION/RULES/$DATETIME"

