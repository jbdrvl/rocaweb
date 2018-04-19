#!/bin/bash

# author: github.com/jbdrvl
# date: August 2017

### DISPLAY HELP INFO
help_function()
{
	local bold=$(tput bold)
	local normal=$(tput sgr0)
	echo "${bold}NAME"
	echo "		${normal}install-hackazon.sh - launches RoCaWeb with Docker and installs Hackazon"
	echo "${bold}SYNOPSIS"
	echo "		${normal}install-hackazon.sh [OPTION] -h [PATH] -d ./path/to/docker [PATH] -j ./path/to/jmeter"
	echo "${bold}DESCRIPTION"
	echo "		${normal}This script launches RoCaWeb with Docker then installs Hackazon and has a test user John Smith sign up on Hackazon."
	echo "		${bold}-h, --help"
	echo "			${normal}displays this help menu"
	echo "		${bold}-d, --docker"
	echo "			${normal}path to the Docker folder where the Docker images are stored. Directory should contain the first Dockerfile that launches everything."
	echo "		${bold}-j, --jmeter"
	echo "			${normal}path to the JMeter folder if JMeter is not implemented in Bash. Directory should contain ./apache-jmeter-3.2/ (with 3.2 being the version of JMeter - may be something else on your machine)."
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
		* ) 		echo -e "${RED}[ERROR]${NC} what is this: $1? This parameter was not expected."
				exit
				;;
	esac
	shift
done

if [ $VERIF_INPUT != 2 ]; then
	echo -e "${RED}[ERROR]${NC} Not enough or too many arguments (was expecting 2 and got $VERIF_INPUT). Please type --help for more information."
	exit
fi

a=$(readlink -f "$0")
MAIN_LOCATION=${a:0:-38}
echo "[DEBUG] main location: $MAIN_LOCATION"

### This script launches the RoCaWeb Docker images and JMeter to start testing

cd $PATH_TO_DOCKER_FOLDER

sudo service apache2 stop
sudo service nginx stop

sudo docker-compose up &

gnome-terminal -e "$MAIN_LOCATION/scripts/launch_jmeter.sh $JMETER_LOCATION $MAIN_LOCATION"
gnome-terminal -e "tail -f ./var/log/apache2/error.log"
