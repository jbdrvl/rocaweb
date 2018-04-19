import csv
import sys

try:
    assert len(sys.argv)==5
except:
    raise AssertionError

def mergeRules(filesPath, numberFiles, mergerPath, startValue):
    '''
        @author         : github.com/jbdrvl
        @date           : July 2017
        
        @parameter      : filesPath [string]    - path to the different .octet-stream rule files
                                e.g. "/home/documents/folder/algorithm/date"
						  
		                  numberFiles [int]		- number of .octet-stream files in filesPath (=number of rules)
                            
      			          mergerPath [string]   - path to the final .conf file which will contain all rules given as input
                                e.g. "/home/documents/folder/final-rules.conf"
                            
        @description    : merge all .octet-stream rule files into one .conf file to be used by RoCaWeb
                            function imports csv module
    '''
    filePathsList=[]
    numberRules=0
    startValue=int(startValue)
    for i in range(1,int(numberFiles)+1):
        filePathsList.append(filesPath+'/'+str(startValue)+str(i)+'.octet-stream')
        startValue+=1
        numberRules+=1
    res = []
    print('imported '+str(numberRules)+' rules')
    # open files
    for filePath in filePathsList:
        try:
            with open(filePath, newline="") as inputFile:
                for row in csv.reader(inputFile):
                    if filePathsList.index(filePath)!=0:
                        if len(row)!=0 and row[0][0]!='#':
                            res.append(row)
                    else:
                        res.append(row)
        except:
            print("[INFO] looks like "+filePath+" does not exist. This may be due to an error with the algorithm when generating the rules with JMeter")
    with open(mergerPath, 'w', newline = '') as csvfile:
        filewriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
        for row in res:
            filewriter.writerow([row][0])
    print(">>> done merging files into "+mergerPath)

mergeRules(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])

