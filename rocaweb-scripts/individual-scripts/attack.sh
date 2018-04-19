#!/bin/bash

# author: github.com/jbdrvl
# date: August 2017

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
ORANGE='\033[1;35m'
NC='\033[0m'
clear

a=$(readlink -f "$0")
MAIN_LOCATION=${a:0:-28}
echo "[DEBUG] main location: $MAIN_LOCATION"

JMETER_TRAINING_SCRIPTS=()
JMETER_ATTACK_SCRIPTS=()


### DISPLAY HELP INFO
help_function()
{
	local bold=$(tput bold)
	local normal=$(tput sgr0)
	echo "${bold}NAME"
	echo "		${normal}attack.sh - launches the given attack script(s) and returns the results as CSV files."
	echo "${bold}SYNOPSIS"
	echo "		${normal}attack.sh [OPTION] -h [PATH] -d ./path/to/docker [PATH] -j ./path/to/jmeter [FILE] -a attacks.jmx [PATH] -af path/to/attack/scripts"
	echo "${bold}DESCRIPTION"
	echo "		${normal}This script launches the given JMeter attack script(s) and save the results in CSV files."
	echo "		${bold}-h, --help"
	echo "			${normal}displays this help menu"
	echo "		${bold}-d, --docker"
	echo "			${normal}path to the Docker folder where the Docker images are stored. Directory should contain the first Dockerfile that launches everything."
	echo "		${bold}-j, --jmeter"
	echo "			${normal}path to the JMeter folder if JMeter is not implemented in Bash. Directory should contain ./apache-jmeter-3.2/ (with 3.2 being the version of JMeter - may be something else on your machine)."
	echo "		${bold}-af, --attackfolder"
	echo "			${normal}directory to JMeter attack scripts used to test the RoCaWeb firewall. Scripts should contain everything to tests attacks on application server."
}

######### VARIABLES #########
VERIF_INPUT=0
# GET PARAMETERS and check their type
while [ "$1" != "" ]; do
	case $1 in
		-h | --help )	clear
				help_function
				exit
				;;
		-d | --docker )	shift
				PATH_TO_DOCKER_FOLDER=$1
				if [[ -d "$PATH_TO_DOCKER_FOLDER" ]]; then
					if [ "${1:0:2}" == "./" ]; then
						PATH_TO_DOCKER_FOLDER="$(pwd)${1:1}"
						echo "[DEBUG] $PATH_TO_DOCKER_FOLDER"					
					fi
					echo -e "${YELLOW}[INFO]${NC} path to Docker folder looks OK: $PATH_TO_DOCKER_FOLDER"
					((VERIF_INPUT++))
				else
					echo -e "${RED}[ERROR]${NC} -d option expected a directory as input - path to Docker folder"
					exit
				fi
				;;
		-j | --jmeter )	shift
				JMETER_LOCATION=$1
				if [[ -d "$JMETER_LOCATION" ]]; then
					if [ "${1:0:2}" == "./" ]; then
						JMETER_LOCATION="$(pwd)${1:1}"
						echo "[DEBUG] $JMETER_LOCATION"					
					fi					
					echo -e "${YELLOW}[INFO]${NC} path to JMeter folder looks OK: $JMETER_LOCATION"
					((VERIF_INPUT++))
				else
					echo -e "${RED}[ERROR]${NC} -f option expected a directory as input - path to JMeter folder"
					exit
				fi
				;;
		-af | --attackfolder ) shift
				if [[ -d "$1" ]]; then					
					VAR=$(ls $1*.jmx)
					for i in ${VAR[*]}
					do						
						if [ "${i:0:2}" == "./" ]; then
							i="$(pwd)${1:1}"
							echo "[DEBUG] $i"
						fi
						JMETER_ATTACK_SCRIPTS+=($i)
					done
				else
					echo -e "${RED}[ERROR]${NC} -af was expecting a directory as input - path to JMeter attack scripts"
					exit
				fi
				;;
		-a | --attack )	shift
				if [ "${1: -4}" == ".jmx" ]; then
					JMETER_ATTACK_TP=$1
					if [ "${1:0:2}" == "./" ]; then
						JMETER_ATTACK_TP="$(pwd)${1:1}"
						echo "[DEBUG] $JMETER_ATTACK_TP"
					fi
					JMETER_ATTACK_SCRIPTS+=($JMETER_ATTACK_TP)
				else
					echo -e "${RED}[ERROR]${NC} Missing attackt JMeter file (.jmx) as -a parameter"
					exit
				fi
				;;
		* ) 		echo -e "${RED}[ERROR]${NC} what is this: $1? This parameter was not expected."
				exit
				;;
	esac
	shift
done

# check if Python3.4 installed
PYTHON_OK="$(which python3.4)"
if [ $PYTHON_OK == "" ]; then
	echo -e "${RED}[OOPS] >>>${NC} Python3.4 required. Please install it before continuing (\$sudo apt-get install python3.4)."
	exit
fi

# check for JMeter attack scripts
if [ ${#JMETER_ATTACK_SCRIPTS[@]} == 0 ]; then
	echo -e "${RED}[ERROR]${NC} Missing at least one JMeter attack script!"
	exit
else
	echo -e "${YELLOW}[INFO]${NC} attack script(s) look(s) OK : ${JMETER_ATTACK_SCRIPTS[*]}"
	((VERIF_INPUT++))
fi

# check if we got all of the required params
if [ $VERIF_INPUT \< 3 ]; then
	echo -e "${RED}[ERROR]${NC} Missing at least one argument (was expecting at least 5 and got $VERIF_INPUT). Please type --help for more information."
	exit
fi

SCRIPTS_LOCATION=$MAIN_LOCATION/scripts

######### SETTING UP #########

restart_function()
{	
	RED='\033[1;31m'
	GREEN='\033[1;32m'
	YELLOW='\033[1;33m'
	NC='\033[0m'
	SCRIPTS_LOCATION=$1
	PATH_TO_DOCKER_FOLDER=$2
	JMETER_LOCATION=$3
	MAIN_LOCATION=$4	
	echo -e "${YELLOW}[INFO]${NC} ending current RoCaWeb session to have it cleanly restart..."
	$SCRIPTS_LOCATION/end_of_tests.sh $PATH_TO_DOCKER_FOLDER

	# waiting for Hackazon to be uninstalled before restarting it
	RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost)
	while [ $RESPONSE != 000 ]; do
		sleep 1
		RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost)
	done

	echo -e "${YELLOW}[INFO]${NC} starting up RoCaWeb..."
	gnome-terminal -x sh -c "$SCRIPTS_LOCATION/launch_docker.sh $PATH_TO_DOCKER_FOLDER $JMETER_LOCATION $MAIN_LOCATION; bash"	

	# WAIT FOR HACKAZON & WEBUI TO BE READY
	# Hackazon
	echo -e "${YELLOW}[INFO]${NC} waiting for Hackazon and Webui to be installed..."
	RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost)
	while [ $RESPONSE != 200 ]; do
		sleep 1
		RESPONSE=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost)
	done
	echo -e "${YELLOW}[SUCCESS]${NC} Hackazon looks good to go: http://localhost."

	# Webui
	WEBUI=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:9000)
	while [ $WEBUI != 200 ]; do
		sleep 1
		WEBUI=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:9000)
	done
	echo -e "${YELLOW}[SUCCESS]${NC} Webui looks good to go: http://localhost:9000."
}

restart_function $SCRIPTS_LOCATION $PATH_TO_DOCKER_FOLDER $JMETER_LOCATION $MAIN_LOCATION
sleep 5 # to make sure JMeter installation script has time to run

######### ATTACKS #########

FINALFOLDER="$(date +%Y-%m-%d_%Hh%M)"
mkdir $MAIN_LOCATION/ATTACKS # if not already created
mkdir $MAIN_LOCATION/ATTACKS/$FINALFOLDER # where files will be saved

for JMX_FILE in ${JMETER_ATTACK_SCRIPTS[*]}
do
	echo -e "${GREEN}[INFO]${NC} attacking with script: $JMX_FILE"
	
	if [ "$JMX_FILE" != "$(echo $JMETER_ATTACK_SCRIPTS)" ];then
		restart_function $SCRIPTS_LOCATION $PATH_TO_DOCKER_FOLDER $JMETER_LOCATION $MAIN_LOCATION
		sleep 5
	fi
	
	NAME=$(python3.4 $MAIN_LOCATION/scripts/python-scripts/getTitleFromJMX.py $JMX_FILE)
	echo -e "[DEBUG] cd '${JMX_FILE/$NAME.jmx}'"
	cd $( echo "${JMX_FILE/$NAME.jmx}")
	pwd
	$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t "$JMX_FILE" -Jlocation=$MAIN_LOCATION/ATTACKS/$FINALFOLDER -Jalgo=$NAME

	echo "[DEBUG] attack results should now be available: $MAIN_LOCATION/ATTACKS/$FINALFOLDER/$NAME.csv"
done

rm $MAIN_LOCATION/jmeter.log 

echo -e "${GREEN}[SUCCESS]${NC} Attack results should now be available in: $MAIN_LOCATION/ATTACKS/$FINALFOLDER"

exit
