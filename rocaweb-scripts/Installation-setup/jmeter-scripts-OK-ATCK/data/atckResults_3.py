import json
import sys
import csv

try:
    assert len(sys.argv)==2
except:
    print(len(sys.argv))
    raise AssertionError

def atckResults(atckCSV):
    '''
        @author         : github.com/jbdrvl
        @date           : August 2017
        
        @parameters     : atckCSV [string] - path to the results file (CSV) of the JMeter attack plan, with expectedType and expectedRespCode
                            
        @description    : returns stats for each algorithm with number of true/false positive/negative
    '''
    rowListAtck=[]  
    with open(atckCSV, newline='') as csvfile:
    	readFile  = csv.reader(csvfile, delimiter=',', quotechar='"')
    	for row in readFile:
    		rowListAtck.append(row)
    dico = {}
    for item in rowListAtck[0][2:-3]:
        dico[item] = {'True Postive':0, 'True Negative':0, 'False Positive':0, 'False Negative':0}
    # True Positive : should have been (not 406) and was (not 406)
    # True Negative : should have been 406 and was 406
    # False Positive : should have been 406 and was (not 406)
    # False Negative : should have been (not 200) and was 406
    counter=0
    for row in rowListAtck[1:]:
        counter+=1
        for i in range(2,len(row)-3):
            if '406' in row[-1]:
                if '406' in row[i]:
                    dico[rowListAtck[0][i]]['True Negative']+=1
                else:
                    dico[rowListAtck[0][i]]['False Positive']+=1
            else:
                if '406' in row[i]:
                    dico[rowListAtck[0][i]]['False Negative']+=1
                else:
                    dico[rowListAtck[0][i]]['True Postive']+=1
    
    return (counter, dico)

print(atckResults(sys.argv[1]))
