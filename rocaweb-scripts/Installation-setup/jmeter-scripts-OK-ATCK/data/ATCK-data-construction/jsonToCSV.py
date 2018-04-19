import json
import sys
import csv

try:
    assert len(sys.argv)==2
except:
    print(len(sys.argv))
    raise AssertionError

def jsonToCSV(filePath):
    '''
        @author         : github.com/jbdrvl
        @date           : July 2017
        
        @parameter      : filePath [string]	- path to the Json file that needs to be converted into a CSV file
                            
        @description    : returns a CSV file containing Json objects (but stored as CSV)
    '''
    with open(filePath) as data_file:
        data=json.load(data_file)
    output = filePath[:-5]+".csv"
    with open(output, 'w', newline = '') as csvfile:
        filewriter = csv.writer(csvfile, delimiter='#', quotechar='|', quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
        for obj in data:
            obj['save']='contact'
            filewriter.writerow([obj])

jsonToCSV(sys.argv[1])
