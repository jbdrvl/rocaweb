#!/bin/bash

# author: github.com/jbdrvl
# date: August 2017

### DISPLAY HELP INFO
help_function()
{
	local bold=$(tput bold)
	local normal=$(tput sgr0)
	echo "${bold}NAME"
	echo "		${normal}stop-rocaweb.sh - stops RoCaWeb with Docker"
	echo "${bold}SYNOPSIS"
	echo "		${normal}stop-rocaweb.sh [OPTION] -h [PATH] -d ./path/to/docker"
	echo "${bold}DESCRIPTION"
	echo "		${normal}This script stops RoCaWeb with Docker."
	echo "		${bold}-h, --help"
	echo "			${normal}displays this help menu"
	echo "		${bold}-d, --docker"
	echo "			${normal}path to the Docker folder where the Docker images are stored. Directory should contain the first Dockerfile that launches everything."
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
		* ) 		echo -e "${RED}[ERROR]${NC} what is this: $1? This parameter was not expected."
				exit
				;;
	esac
	shift
done

if [ $VERIF_INPUT != 1 ]; then
	echo -e "${RED}[ERROR]${NC} Not enough or too many arguments (was expecting 1 and got $VERIF_INPUT). Please type --help for more information."
	exit
fi

cd $PATH_TO_DOCKER_FOLDER

sudo docker-compose down

echo "[INFO] if an error occurs during the compose down: sudo docker rm -f \$(sudo docker ps -a -q)"
