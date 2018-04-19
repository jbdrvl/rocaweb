import csv
import sys

try:
    assert len(sys.argv)==3
except:
    print(sys.argv)
    raise AssertionError

def findAllNodes(filePath, finalCSVPath):
    '''
        @author         : github.com/jbdrvl
        @date           : July 2017
        
        @parameter      : filePath [string]     - path to the octet-stream file imported from Visualizing Page in RoCaWeb through JMeter
                                e.g. "/home/documents/folder/file.octet-stream"
                            
                          finalCSVPath [string] - path to save the final CSV file that the program will return 
                                e.g. "/home/documents/folder/final.csv"
                          
        @description    : imports the octet-stream file (can be .txt file as well) and reads it to select all end-nodes, which will be then used by RoCaWeb for the firewall rules
                            function imports csv module
    '''
    res = []
    # open file
    with open(filePath, newline="") as inputFile:
        for row in csv.reader(inputFile):
            res.append(row)
    # transform the whole thing into one big String
    resStr = ''
    for subList in res:
        inter = ''
        for item in subList:
            inter+=item 
        resStr+=inter
    # only keep end-nodes and store them into resList
    resList=[]
    while resStr.find("text")!=-1:
        index=resStr.find("text")
        indexStart=resStr[index+1:].find('"')+index+1
        indexEnd=resStr[indexStart+1:].find('"')+indexStart+1
        if resStr[indexEnd+1]=="}": # meaning it is an end-node
            resList.append(resStr[indexStart+1:indexEnd])
        resStr=resStr[indexEnd+1:]
    with open(finalCSVPath, 'w', newline = '') as csvfile:
        filewriter = csv.writer(csvfile, delimiter=',',quotechar='|', quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
        for row in resList:
            filewriter.writerow([row])
    print(">>> done writing file "+finalCSVPath)

findAllNodes(sys.argv[1], sys.argv[2])
