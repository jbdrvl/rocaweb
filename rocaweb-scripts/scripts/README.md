# rocaweb-scripts/scripts

This directory is meant to be used only by main scripts in **rocaweb-scripts**. 

## SCRIPTS

### **launch_docker.sh**
Launches RoCaWeb images with Docker using *docker-compose up* then launches **./launch_jmeter.sh**.
If needed, the user can uncomment the last line in the script to display in another terminal the logs for RoCaWeb. 
### **launch_jmeter.sh**
Uses JMeter scripts - in **./jmeter-scripts/** - to install Hackazon (database settings, etc...) then has a test user John Smith sign up.
### **end_of_tests.sh**
Uses *docker-compose down* to stop RoCaWeb images.
### **rules_production_all.sh**
In charge of creating the ModSecurity rules from PDML files using the RoCaWeb WebUI. It first pre-processes the data using WebUI, then launches **./rules_production_all_indiv.sh** for each of the algorithms contained in **../algo_list.txt**.
### **rules_production_all_indiv.sh**
For a given algorithm, creates the ModSecurity rules associated with the data it gets from **./rules_production_all.sh**, and imports the rules into *.txt* files. A Python script then merges these files into one *.conf* file, named after the given algorithm. 
It stores the *.conf* file in a directory with the others *.conf* files from the same session. 

## DIRECTORIES

### **./jmeter-scripts**
* **launch_installation_hackazon.jmx** - installs Hackazon: admin + database settings
* **launch_john_smith_signs_up.jmx** - has John Smith sign up on Hackazon as a test user
* **rules_production_jmeter_CLUSTERIZE.jmx** - clusterizes data from PDML file to *.octet-stream* file
* **rules_production_jmeter_RUN.jmx** - uses the *.octet-stream* file to generate the ModSecurity rules
* **rules_production_jmeter_IMPORT.jmx** - imports all of the newly created rules into *.txt* files

### **./python-scripts**
* **findAllNodes.py** - imports the *.octet-stream* file and extracts all 'end-nodes' out of it, to be used when creating rules
* **getTitleFromJMX.pu** - returns the title of the JMX file it got the full path of as input
* **getTSharkPID.py** - returns T-Shark PID
* **mergeAttackResults.py** - merges all .csv files into one .csv file with all results
* **mergeRules.py** - merge all *.octet-stream* rule files into one *.conf* file
* **parseJson.py** - returns the number of 'primary' objects in a given *.json* file
