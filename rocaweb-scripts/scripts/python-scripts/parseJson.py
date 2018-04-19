import json
import sys

try:
    assert len(sys.argv)==2
except:
    print(len(sys.argv))
    raise AssertionError

def parseJson(filePath):
    '''
        @author         : github.com/jbdrvl
        @date           : July 2017
        
        @parameter      : filePath [string]	- path to the json file that needs parsings
                            
        @description    : returns the number of 'primary' objects in the json file
    '''
    with open(filePath) as data_file:
        data=json.load(data_file)
    return len(data)
    
print(parseJson(sys.argv[1]))
