# rocaweb-scripts/individual-scripts

These scripts are meant to be used independently for specific tests by users.

## SCRIPTS

### **generate-rules-from-pdml.sh**
* *inputs*
    * PDML file with data to be used to produce ModSecurity rules with RoCaWeb WebUI
    * website title (used by the script to name newly created files)
    * path to JMeter directory, which should contain **./apache-jmeter-3.2/bin/jmeter.sh** 
* *info*
    * The script uses the PDML file to create ModSecurity rules through RoCaWeb WebUI, with the different algorithms contained in **./algo_list.txt**. It saves all the rules into one directory. 
* *important*
    * RoCaWeb WebUI should be up and running when launching this script.
* *testing*
```bash
./Documents/rocaweb-scripts/individual-scripts/generate-rules-from-pdml.sh -j ./Téléchargements -w hackazon -f /path/to/file.pdml
```

### **install-hackazon.sh**
* *input*
    * path to the Docker folder where the script will find the Dockerfile to launch RoCaWeb
    * path to JMeter directory, which should contain **./apache-jmeter-3.2/bin/jmeter.sh**
* *info*
    * This script launches RoCaWeb with Docker - *./scripts/launch_jmeter.sh* - then installs Hackazon and has a test user John Smith sign up on Hackazon.
* *testing*
```bash
./Documents/rocaweb-scripts/individual-scripts/install-hackazon.sh -j ./Téléchargements -d ./Documents/docker
```

### **stop-rocaweb.sh**
* *input*
    * path to the Docker folder where the script will find the Dockerfile to launch RoCaWeb
* *info*
    * This script stops RoCaWeb with Docker.
* *testing*
```bash
./Documents/rocaweb-scripts/individual-scripts/stop-rocaweb.sh -d ./Documents/docker
```

### **attack.sh**
* *input*
    * path to the Docker folder where the script will find the Dockerfile to launch RoCaWeb
    * path to JMeter directory, which should contain **./apache-jmeter-3.2/bin/jmeter.sh**
    * JMeter attack script or folder with several JMeter attack scripts
* *info*
    * This script takes as input several JMeter attack scripts and launches them to test Hackazon. For each of the attack scripts, the results are saved into a CSV file. All of the final CSV files are stored in one directory. 
* *important*
    * This script only takes in charge JMeter script files. Rules - as *.conf* files - should already be in **docker/agent/rules/**. The script will not manipulate/change/delete/move the rules. 
* *testing*
```bash
./Documents/rocaweb-scripts/individual-scripts/attack.sh -d ./Documents/docker/ -j ./Téléchargements/ -a ./Documents/rocaweb-scripts/Installation-setup/jmeter-scripts-OK-ATCK/ATCK/search_bar_ATCK.jmx
```

## ADDITIONAL INFO

### CSV files for the JMeter scripts
* The JMeter scripts might require CSV files with data to use in their http requests. The CSV Config elements in the JMeter scripts should be done when writing the JMeter script. The Shell script do NOT take those CSV files into account. 
* Before running a JMeter script (training or attack), the script changes its path to the script's path. So the CSV file can be called using a relative path:
    * JMeter training script in **/home/user/Documents/JMeter_files/training.jmx**
    * CSV file is in **/home/user/Documents/JMeter_files/data/file.csv**
    * The Shell scripts will *cd* to **/home/user/Documents/JMeter_files** before launching the script
    * in **training.jmx**, the CSV Config element must call for **./data/file.csv** or **/home/user/Documents/JMeter_files/data/file.csv**

