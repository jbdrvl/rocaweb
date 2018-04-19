import json
import sys

try:
    assert len(sys.argv)==2
except:
    print(len(sys.argv))
    raise AssertionError

def getTitleFromJMX(filePath):
    '''
        @author         : github.com/jbdrvl
        @date           : August 2017
        
        @parameter      : filePath [string]	- path to the JMX file from which we need to extract the title
                            
        @description    : returns the title of the JMX file it got the full path of as input
    '''
    indexSlash = filePath.find("/")
    while indexSlash!=-1:
        filePath=filePath[indexSlash+1:]
        indexSlash = filePath.find("/")
    return filePath[:-4]
    
print(getTitleFromJMX(sys.argv[1]))
