# ATCK DATA CONSTRUCTION
In this directory are stored the CSV and Json files we used to generate some of the CSV files in **../../data/** that are used by the JMeter scripts. The Python scripts are the ones used to generate the finale CSV files from the initial CSV/Json files.

## **generateAtckCSV.py**
* *input*
    * input CSV file with specific data (/datatypes), typically gotten from Mockaroo
    * name of the output CSV file (with *.csv* extension)
    * number of (data, datatypes) pairs that are wanted for the output CSV file
* *info*
    * uses as input a CSV file with specific data (/datatypes) to create a CSV file with random (data, datatypes), chosen from the input file. It returns as many random pairs as needed.

## **jsonToCSV.py**
* *input*
    * path to the Json file that needs to be converted into a CSV file
* *info*
    * returns a CSV file containing Json objects (but stored as CSV)
