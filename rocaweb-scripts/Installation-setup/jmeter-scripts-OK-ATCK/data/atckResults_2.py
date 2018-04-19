import json
import sys
import csv

try:
    assert len(sys.argv)==3
except:
    print(len(sys.argv))
    raise AssertionError

def atckResults(inputCSV, atckCSV):
    '''
        @author         : github.com/jbdrvl
        @date           : August 2017
        
        @parameters     : inputCSV [string] - path to the CSV file used by the JMeter attack script we are studying
        
                          atckCSV [string] - path to the results file (CSV) of the JMeter attack plan, with expectedType
                            
        @description    : adds to the CSV file what response code is expected according to the expected type and what data it got during the attack script
    '''
    rowListSrc=[]; rowListAtck=[]  
    with open(inputCSV, newline='') as csvfile:
    	readFile  = csv.reader(csvfile, delimiter=',', quotechar='"')
    	for row in readFile:
    		rowListSrc.append(row)
    with open(atckCSV, newline='') as csvfile:
    	readFile  = csv.reader(csvfile, delimiter=',', quotechar='"')
    	for row in readFile:
    		rowListAtck.append(row)
    row1 = rowListAtck[1]
    rowListAtck[0].append('expectedRespCode')
    jumpIndex = rowListAtck[2:].index(row1)+1
    indexSource=1
    for i in range(1,len(rowListAtck),jumpIndex):
        for j in range(i, i+jumpIndex):
            if 'ATCK' not in rowListAtck[j][0]:
                rowListAtck[j].append('200 OK')
            else:
                if rowListSrc[indexSource][1] in rowListAtck[j][-1]:
                    rowListAtck[j].append('200 OK')
                else:
                    rowListAtck[j].append('406 Not Acceptable')
        indexSource+=1
    with open(atckCSV[:-4]+'_2.csv', 'w', newline = '') as csvfile:
    	filewriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
    	for row in rowListAtck:
    	    filewriter.writerow(row)

print(atckResults(sys.argv[1], sys.argv[2]))
