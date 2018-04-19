import csv
import sys
import random as rd

try:
    assert len(sys.argv)==4
except:
    raise AssertionError

def generateAtckCSV(source, output, num):
    '''
        @author         : github.com/jbdrvl
        @date           : August 2017
        
        @parameter      : source [string]   - full path+name to input CSV file
                                e.g. "/home/documents/inputFile.csv"
						  
			  			  output [string]	- full path+name to be given to the output CSV file
			  			  		e.g. "/home/documents/outputFile.csv"
			  			  		                            
              			  num [integer]   	- number of rows the final CSV file should contain
                            
        @description    : uses as input a CSV file with specific data (/datatypes) to create a CSV file with random (data, datatypes), chosen from the input file. It returns as many random pairs as needed.
								function imports csv module
    ''' 
    dico = {}; rowList=[]  
    with open(source, newline='') as csvfile:
    	readFile  = csv.reader(csvfile, delimiter=',', quotechar='"')
    	for row in readFile:
    		#while len(row)>=16: 
    			#item = row[14]
    			#row.remove(item)
    			#row[13] = row[13]+','+item
    		rowList.append(row)
    for item in rowList[0]:
    	dico[item]=[]
    for row in rowList:
    	for i in range(len(row)):
            #print(rowList[0], i, row)
            dico[rowList[0][i]].append(row[i])
    print("dico - ok")
    dataTypeList = [item for item in dico] 
    with open(output, 'w', newline = '') as csvfile:
        filewriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
        filewriter.writerow(['data', 'datatype'])
        for i in range(int(num)-1):
            dataTypeNbr = rd.randint(0, len(dataTypeList)-1)
            dataType = dataTypeList[dataTypeNbr]
            dataNbr = rd.randint(0, len(dico[dataType])-1)
            dataRd = dico[dataType][dataNbr]
            row = [dataRd, dataType]
            filewriter.writerow(row)

generateAtckCSV(sys.argv[1], sys.argv[2], sys.argv[3])
