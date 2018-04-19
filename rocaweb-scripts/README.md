# rocaweb-scripts

This folder contains scripts to install, train and test the RoCaWeb firewall and the Hackazon web application. 
Right in **rocaweb-scripts/** are **launch.sh** and **algo_list.txt**, which are described below. 
**launch.sh** is the main script: it takes as inputs JMeter scripts (training and attack scripts) to generate ModSecurity rules from the training scripts and test the firewall with the attack scripts.
The ModSecurity rules are produced from different algorithms listed in **algo_list.txt**

Then come a few directories:
* **individual-scripts/** - contains scripts that are meant to be used independently for specific tests by users. They are all extracted from **launch.sh** but are independent.
* **scripts/** - contains sub-scripts used by **launch.sh** and the individual scripts. Except for the T-Shark filter, those should not require changes.*
* **Installation-setup/** - contains JMeter scripts to be used when testing Hackazon and RoCaWeb. 
* **RULES** - contains the ModSecurity rules produced by RoCaWeb
* **ATTACKS** - contains the results from the JMeter attack scripts

Please read the **IMPORTANT INFO** section below.

## MAIN SCRIPTS

### **launch.sh**
* *inputs*
    * JMeter training script or folder with several JMeter training scripts
    * JMeter attack script or folder with several JMeter attack scripts
    * website title (used by the script to name newly created files)
    * path to the Docker folder where the script will find the Dockerfile to launch RoCaWeb
    * path to JMeter directory, which should contain **./apache-jmeter-3.2/bin/jmeter.sh** 
* *info*
    * This script takes as input several JMeter training scripts, which will be used to generate clean traffic between clients and the web server. This clean traffic is recorded with T-Shark and exported into PDML files (one for each of the training script). The PDML files are then used to create ModSecurity rules, using the RoCaWeb WebUI, with the different algorithms found in **./algo_list.txt**. These rules are then tested with the different JMeter attack scripts (given as inputs). For each of the attack scripts, the rules corresponding to the different algorithms are used and the results are merged into one CSV file. All of the final CSV files are stored in one directory. 
* *testing*
```bash
./Documents/rocaweb-scripts/launch.sh -af /home/rocaweb/Documents/rocaweb-scripts/Installation-setup/jmeter-scripts-OK-ATCK/ATCK/ -tf /home/rocaweb/Documents/rocaweb-scripts/Installation-setup/jmeter-scripts-OK-ATCK/OK/ -w hackazon -j /home/rocaweb/Téléchargements/ -d /home/rocaweb/Documents/docker/

./rocaweb-scripts/launch.sh -d ./docker/ -j /home/rocaweb/Téléchargements/ -a ./rocaweb-scripts/Installation-setup/jmeter-scripts-OK-ATCK/ATCK/search_bar_ATCK.jmx -t ./rocaweb-scripts/Installation-setup/jmeter-scripts-OK-ATCK/OK/search_bar_OK.jmx -w hackazon
 
```

### **algo_list.txt**
This file lists the algorithms that Shell scripts will use when producing ModSecurity rules with the RoCaWeb WebUI. 
The algorithms are:
* AMAA - ready as *amaa*
* AttributeCharacterDistribution - not yet available as *acd*
* AttributeLength - ready as *attributelength*
* BoxPlot - not yet available as *boxplot*
* CrossValidation - ready as *crossvalidation*
* Kolmogorov - not yet available as *kolmogorov*
* QualityControl - ready as *qualitycontrol*
* RegexLearner - ready as *regexlearner*
* TokenFinder - not yet available as *tokenfinder*
* TRIE - not yet available as *trie*


### **individual-scripts/**
This directory contains scripts that are meant to be used independently for specific tests by users:
* **generate-rules-from-pdml.sh**
* **install-hackazon.sh**
* **stop-rocaweb.sh**
* **attack.sh**
Please refer to **./individual-scripts/README.md** for more information.

## IMPORTANT INFO

### Relative paths
Scripts can take in relative paths as inputs but only with **./**. They do not take in relative paths starting with **../**.

### CSV files for the JMeter scripts
* The JMeter scripts might require CSV files with data to use in their http requests. The CSV Config elements in the JMeter scripts should be done when writing the JMeter script. The Shell script do NOT take those CSV files into account. 
* Before running a JMeter script (training or attack), the script changes its path to the script's path. So the CSV file can be called using a relative path:
    * JMeter training script in **/home/user/Documents/JMeter_files/training.jmx**
    * CSV file is in **/home/user/Documents/JMeter_files/data/file.csv**
    * **launch.sh** will *cd* to **/home/user/Documents/JMeter_files** before launching the script
    * in **training.jmx**, the CSV Config element must call for **./data/file.csv** or **/home/user/Documents/JMeter_files/data/file.csv**

### T-Shark filter
In **./launch.sh**, the user might need to change in the T-Shark display filter the IP address. The address needed is that of the web server. 
One can find it using WireShark (GUI): sending requests to the web server while monitoring the traffic on WireShark (if not https).
