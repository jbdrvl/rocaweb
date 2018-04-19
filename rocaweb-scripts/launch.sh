#!/bin/bash

# author: github.com/jbdrvl
# date: August 2017

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
ORANGE='\033[1;35m'
NC='\033[0m'
clear

alias echo="/bin/echo"

a=$(/bin/readlink -f "$0")
MAIN_LOCATION=${a:0:-10}
echo "[DEBUG] main location: $MAIN_LOCATION"

ALGO_LIST="$(/bin/cat $MAIN_LOCATION/algo_list.txt)" #('crossvalidation' 'amaa' 'attributelength' 'qualitycontrol' 'regexlearner') # 'acd'
echo "[DEBUG] algo list: ${ALGO_LIST[*]}"
JMETER_TRAINING_SCRIPTS=()
JMETER_ATTACK_SCRIPTS=()
VERIF_INPUTS=0

### DISPLAY HELP INFO
help_function()
{
	local bold=$(tput bold)
	local normal=$(tput sgr0)
	echo "${bold}NAME"
	echo "		${normal}all.sh - returns test results from attacks towards website"
	echo "${bold}SYNOPSIS"
	echo "		${normal}all.sh [OPTION] -h [PATH] -d ./path/to/docker [PATH] -j ./path/to/jmeter [FILE] -t train.jmx [PATH] -tf path/to/training/scripts [FILE] -a attacks.jmx [PATH] -af path/to/attack/scripts [STRING] -w title"
	echo "${bold}DESCRIPTION"
	echo "		${normal}This script uses a JMeter training script that generates clean traffic between virtual clients and the website to train the RoCaWeb firewall and create firewall rules that will be tested with a JMeter attack script."
	echo "		${bold}-h, --help"
	echo "			${normal}displays this help menu"
	echo "		${bold}-d, --docker"
	echo "			${normal}path to the Docker folder where the Docker images are stored. Directory should contain the first Dockerfile that launches everything."
	echo "		${bold}-j, --jmeter"
	echo "			${normal}path to the JMeter folder if JMeter is not implemented in Bash. Directory should contain ./apache-jmeter-3.2/ (with 3.2 being the version of JMeter - may be something else on your machine)."
	echo "		${bold}-tf, --trainfolder"
	echo "			${normal}directory to JMeter training scripts used to train RoCaWeb. Scripts should contain everything to generate clean traffic between virtual users and server."
	echo "		${bold}-t, --train"
	echo "			${normal}JMeter script used to train RoCaWeb. Script should contain everything to generate clean traffic between virtual users and server."
	echo "		${bold}-af, --attackfolder"
	echo "			${normal}directory to JMeter attack scripts used to test the RoCaWeb firewall. Scripts should contain everything to tests attacks on application server."
	echo "		${bold}-w, --web"
	echo "			${normal}title of the website being tested. The title will be used to name rule and result files."
}

######### VARIABLES #########

# GET PARAMETERS and check their type
while [ "$1" != "" ]; do
	case $1 in
		-h | --help )	/usr/bin/clear
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
		-tf | --trainfolder ) shift
				if [[ -d "$1" ]]; then
					VAR=$(ls $1*.jmx)
					for i in ${VAR[*]}
					do
						if [ "${i:0:2}" == "./" ]; then
							i="$(pwd)${1:1}"
							echo "[DEBUG] $i"
						fi
						JMETER_TRAINING_SCRIPTS+=($i)
					done
				else
					echo -e "${RED}[ERROR]${NC} -tf was expecting a directory as input - path to JMeter training scripts"
					exit
				fi
				;;
		-t | --train )	shift
				if [ "${1: -4}" == ".jmx" ]; then
					JMETER_TRAINING_TP=$1
					if [ "${1:0:2}" == "./" ]; then
						JMETER_TRAINING_TP="$(pwd)${1:1}"
						echo "[DEBUG] $JMETER_TRAINING_TP"
					fi
					JMETER_TRAINING_SCRIPTS+=($JMETER_TRAINING_TP)
				else
					echo "${RED}[ERROR]${NC} Missing training JMeter file (.jmx) as -t parameter"
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
		-w | --web )	shift
				WEBSITE_TITLE=$1
				echo -e "${YELLOW}[INFO]${NC} Website title: $WEBSITE_TITLE"
				((VERIF_INPUT++))
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

# check for JMeter training and attack scripts
if [ ${#JMETER_TRAINING_SCRIPTS[@]} == 0 ]; then
	echo -e "${RED}[ERROR]${NC} Missing at least one JMeter training script!"
	exit
else
	echo -e "${YELLOW}[INFO]${NC} training script(s) look(s) OK : ${JMETER_TRAINING_SCRIPTS[*]}"
	((VERIF_INPUT++))
fi

if [ ${#JMETER_ATTACK_SCRIPTS[@]} == 0 ]; then
	echo -e "${RED}[ERROR]${NC} Missing at least one JMeter attack script!"
	exit
else
	echo -e "${YELLOW}[INFO]${NC} attack script(s) look(s) OK : ${JMETER_ATTACK_SCRIPTS[*]}"
	((VERIF_INPUT++))
fi

# check if we got all of the required params
if [ $VERIF_INPUT \< 5 ]; then
	echo -e "${RED}[ERROR]${NC} Missing at least one argument (was expecting at least 5 and got $VERIF_INPUT). Please type --help for more information."
	exit
fi

SCRIPTS_LOCATION=$MAIN_LOCATION/scripts

######### SETTING UP #########
RULES_DIR=$PATH_TO_DOCKER_FOLDER/agent/rules
/bin/rm $RULES_DIR/*.conf

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




######### TRAINING TIME #########


# GETTING T-SHARK READY
echo -e "${YELLOW}[INPUT]${NC} We first need to know which network interface we will be listening on."
echo "[DEBUG] launching wireshark GUI"
gnome-terminal -e "wireshark"
echo "[DEBUG] launching iceweasel new tab localhost"
gnome-terminal -e "iceweasel --new-tab localhost"

tshark -D
echo -e "${ORANGE}[INPUT]${NC} After analyzing with WireShark GUI, which network interface do we need to listen to?"
echo -e "${YELLO}[INFO] Please select the network interface corresponding to the IP of the tested website (e.g. 172.20.0.1 for our tests)${NC}"
read INTERFACE
echo -e "[DEBUG] $INTERFACE."







######## PDML FILES #########
PDML_FILES=()

for JMX_FILE in ${JMETER_TRAINING_SCRIPTS[*]}
do
	echo -e "${GREEN}[INFO]${NC} Generating PDML file for ${GREEN}$JMX_FILE${NC}."
	DATETIME="$(date +%Y-%m-%d_%Hh%Mm%Ss)"
	PDML_FILES+=($DATETIME)
	
	# LAUNCHING WIRESHARK IN BCKGRND
	echo -e "${YELLOW}[INFO]${NC} launching T-Shark in the background..."
	tshark -i $INTERFACE -T pdml -Y "http.request && not http.request.uri matches \"(jpg|css|png|gif|js)\$\" && ip.dst==172.20.0.3" > $MAIN_LOCATION/$DATETIME.pdml &

	sleep 5 # so that T-Shark gets ready

	# LAUNCHING JMETER SCRIPT
	echo -e "${YELLOW}[INFO]${NC} launching the JMeter script."
	NAME=$(python3.4 $MAIN_LOCATION/scripts/python-scripts/getTitleFromJMX.py $JMX_FILE)
	echo -e "[DEBUG] cd '${JMX_FILE/$NAME.jmx}'"
	cd $( echo "${JMX_FILE/$NAME.jmx}")
	$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t $JMX_FILE

	echo -e "${YELLOW}[INFO]${NC} stopping T-Shark from recording, and saving data."
	sleep 7
	kill $(python3.4 $MAIN_LOCATION/scripts/python-scripts/getTSharkPID.py $(ps -C tshark -o pid))

	if test -f $MAIN_LOCATION/$DATETIME.pdml
	then
		echo -e "${YELLOW}[SUCCESS]${NC} PDML file ready: $MAIN_LOCATION/$DATETIME.pdml"
	else
		echo -e "${RED}[ERROR]${NC} an error occured during the script. Please analyze logs for more information."
		exit
	fi
done



######### CREATING RULES #########

FOLDERS=()

for DATETIME in ${PDML_FILES[*]}
do
	if [ "$DATETIME" != "$(echo $PDML_FILES)" ];then
		restart_function $SCRIPTS_LOCATION $PATH_TO_DOCKER_FOLDER $JMETER_LOCATION $MAIN_LOCATION
	fi
	echo -e "[DEBUG] Production of rules for PDML file : $DATETIME.pdml"
	$MAIN_LOCATION/scripts/rules_production_all.sh $MAIN_LOCATION/$DATETIME.pdml a $JMETER_LOCATION $WEBSITE_TITLE $MAIN_LOCATION

	echo "[DEBUG] $MAIN_LOCATION/$DATETIME.pdml"
	rm $MAIN_LOCATION/$DATETIME.pdml
	echo -e "${ORANGE}[INPUT]${NC} Enter the date-time corresponding to the folder where the rules were stored - should be displayed in ${GREEN}green${NC} not far above from here."
	read FOLDER
	if [ $FOLDER == "" ]; then
		echo -e "${RED}[ERROR]${NC} An error occured while trying to get the folder where the rules are stored. You probably did not enter the date-time in the right format."
		exit
	fi
	FOLDERS+=($FOLDER)
done

if [ ${#FOLDERS[@]} != ${#PDML_FILES[@]} ]; then
	echo -e "${RED}[ERROR]${NC} An error occured while creating the rules with the PDML files."
	exit
else
	echo -e "${YELLOW}[SUCCESS]${NC} Looks like everything went well when generating rules."
	echo "[DEBUG] ${FOLDERS[*]}"
fi

echo -e "${YELLOW}[INFO]${NC} rules are ready so we can now launch the attack scripts."




######### ATTACKS #########

RULES_DIR=$PATH_TO_DOCKER_FOLDER/agent/rules

FINALFOLDER="$(date +%Y-%m-%d_%Hh%M)"
mkdir $MAIN_LOCATION/ATTACKS # if not already created
mkdir $MAIN_LOCATION/ATTACKS/$FINALFOLDER # where files will be saved

for JMX_FILE in ${JMETER_ATTACK_SCRIPTS[*]}
do
	echo -e "${GREEN}[INFO]${NC} attacking with script: $JMX_FILE"
	# creating temporary folder to store results corresponding to each algo
	DATETIME="$(date +%Y-%m-%d_%Hh%Mm%Ss)"
	mkdir $MAIN_LOCATION/ATCK-$DATETIME # temporary folder
	
	# test everything with no Modsecurity rule
	echo -e "${YELLOW}ALGORITHM: none${NC}"
	echo -e "${YELLOW}[INFO]${NC} removing all rules from Docker rules directory..."
	rm $RULES_DIR/*.conf
	restart_function $SCRIPTS_LOCATION $PATH_TO_DOCKER_FOLDER $JMETER_LOCATION $MAIN_LOCATION
	sleep 5 # to make sure JMeter installation script has time to run
	NAME=$(python3.4 $MAIN_LOCATION/scripts/python-scripts/getTitleFromJMX.py $JMX_FILE)
	echo -e "[DEBUG] cd '${JMX_FILE/$NAME.jmx}'"
	cd $( echo "${JMX_FILE/$NAME.jmx}")
	$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t "$JMX_FILE" -Jlocation=$MAIN_LOCATION/ATCK-$DATETIME -Jalgo=none
	
	for i in ${ALGO_LIST[*]}
	do
		echo -e "${YELLOW}ALGORITHM: $i${NC}"
		echo "[DEBUG] copying $i rule files into Docker rules directory..."
		# empty rules directory from previous rules	
		rm $RULES_DIR/*.conf
		echo "[DEBUG] rules dir empty"
		# install the right rules into rules directory	
		COUNTER=1
		for DATETIME_INPUT in ${FOLDERS[*]}
		do
			echo "[DEBUG] copying $DATETIME_INPUT/$WEBSITE_TITLE-$i* into $RULES_DIR/$i-$COUNTER.conf"
			cp $DATETIME_INPUT/$WEBSITE_TITLE-$i* $RULES_DIR/$i-$COUNTER.conf
			((COUNTER++))
		done
		restart_function $SCRIPTS_LOCATION $PATH_TO_DOCKER_FOLDER $JMETER_LOCATION $MAIN_LOCATION
		sleep 5 # to make sure JMeter installation script has time to run
		NAME=$(python3.4 $MAIN_LOCATION/scripts/python-scripts/getTitleFromJMX.py $JMX_FILE)
		echo -e "[DEBUG] cd '${JMX_FILE/$NAME.jmx}'"
		cd $( echo "${JMX_FILE/$NAME.jmx}")		
		$JMETER_LOCATION/apache-jmeter-3.2/bin/jmeter -n -t "$JMX_FILE" -Jlocation=$MAIN_LOCATION/ATCK-$DATETIME -Jalgo=$i
	done
	
	ALGO_LIST+=("none")
	echo "[DEBUG] ${ALGO_LIST[*]}"
	
	# merge Attack Results
	NAME=$(python3.4 $MAIN_LOCATION/scripts/python-scripts/getTitleFromJMX.py $JMX_FILE)
	python3.4 $MAIN_LOCATION/scripts/python-scripts/mergeAttackResults.py $MAIN_LOCATION/ATCK-$DATETIME ${ALGO_LIST[*]} $MAIN_LOCATION/ATTACKS/$FINALFOLDER/$NAME.csv #DATETIME.csv
	
	echo "[DEBUG] attack results should now be available: $MAIN_LOCATION/ATTACKS/$FINALFOLDER/$DATETIME.csv"
	rm -r $MAIN_LOCATION/ATCK-$DATETIME
	DEL=("none")
	ALGO_LIST=( "${ALGO_LIST[*]/$DEL}" )
	echo "[DEBUG] ${ALGO_LIST[*]}"
	
done

rm $MAIN_LOCATION/jmeter.log 

echo -e "${GREEN}[SUCCESS]${NC} Attack results should now be available in: $MAIN_LOCATION/ATTACKS/$FINALFOLDER"

exit
