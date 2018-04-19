import csv
import sys

try:
    assert len(sys.argv)>=4
except:
    raise AssertionError

def mergeAttackResults(filesPath, algoList, mergerPath):
    '''
        @author         : github.com/jbdrvl
        @date           : July 2017
        
        @parameter      : filesPath [string]    - path to the different .csv results files
                                e.g. "/home/documents/folder/date"
						  
						  algoList [list]		- list of the algorithm that have been tested with JMeter
                            
              			  mergerPath [string]   - path to the final CSV file containing the overall results of the different algorithms
                                e.g. "/home/documents/folder/final-results.csv"
                            
        @description    : merge all .csv files into one .csv file with all results
                            function imports csv module
    ''' 
    # enters all data into one dictionnary with dico[algo] = [[first row], [second row], ...]
    dico = {}  
    for algo in algoList:
        path = filesPath+'/'+algo+'.csv'
        with open(path, newline="") as inputFile:
            dico[algo]=[]
            for row in csv.reader(inputFile):
                dico[algo].append(row)
    # for each row, puts responseCode and responseMessage together (e.g. ['202', 'OK'] > ['202 OK'])
    for algo in dico:
        for row in dico[algo]:
            row[1] = row[1]+' '+row[2]
            row.remove(row[2])
    # builds each new row with data from all algorithms and writes them into new CSV file
    with open(mergerPath, 'w', newline = '') as csvfile:
        filewriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
        filewriter.writerow(['label', 'URL']+[algo for algo in algoList])
        for i in range(1,len(dico[algoList[0]])):
            row = constructRow([dico[algo][i] for algo in algoList])
            filewriter.writerow(row)

def constructRow(rowList):
    '''
        intern function to contruct each row (except the first one) with [label, URL, responseForAlgo1, responseForAlgo2, ...]
    '''
    newRow = []
    newRow.append(rowList[0][0])
    newRow.append(rowList[0][2])
    for row in rowList:
        newRow.append(row[1])
    return newRow

#print(sys.argv)

mergeAttackResults(sys.argv[1], sys.argv[2:-1], sys.argv[-1])

