import json
import sys
import csv

try:
    assert len(sys.argv)==2
except:
    print(len(sys.argv))
    raise AssertionError

def addExpType(atckCSV):
    '''
        @author         : github.com/jbdrvl
        @date           : August 2017
        
        @parameters     : atckCSV [string]     - path to the results CSV file from the JMeter attack script we are studying
                            
        @description    : adds to all rows of the CSV file what type of parameter is expected for the given http request
                          only for purchase and signup so far
    '''
    rowListAtck=[]  
    with open(atckCSV, newline='') as csvfile:
    	readFile  = csv.reader(csvfile, delimiter=',', quotechar='"')
    	for row in readFile:
    		rowListAtck.append(row)
    rowListAtck[0].append('exectedType')
    for row in rowListAtck[1:]:
        if 'ATCK' in row[0]:
            if 'card_nbr' in row[0]:
                row.append('card_number')
            elif 'country' in row[0]:
                row.append('country_id')
            elif 'phone' in row[0]:
                row.append('phone blank')
            elif 'full_form' in row[0]:
                row.append('1')
            elif ('csrf' in row[0]) or ('confirmation' in row[0]):
                row.append('')
            elif ('product_id' in row[0]) or ('click-item' in row[0]) or ('qty' in row[0]) or ('exp_month' in row[0]) or ('exp_year' in row[0]) or ('cvv' in row[0]) or ('zip' in row[0]):
                row.append('cvv')
            elif ('first_name' in row[0]) or ('last_name' in row[0]) or ('shipping' in row[0]) or ('payment' in row[0]) or ('full_name' in row[0]) or ('address1' in row[0]) or ('city' in row[0]) or ('region' in row[0]):
                row.append('words')
            elif ('address_id' in row[0]) or ('address2' in row[0]):
                row.append('words blank')
            elif 'email' in row[0]:
                row.append('email')
            elif ('password' in row[0]) or ('username' in row[0]):
                row.append('password username')
            else:
                print('[ERROR] not accounted for: '+row[0])
        else:
            row.append('')
    with open(atckCSV[:-4]+'_STUDY.csv', 'w', newline = '') as csvfile:
    	filewriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL, lineterminator='\n')
    	for row in rowListAtck:
    	    filewriter.writerow(row)
    	   




print(addExpType(sys.argv[1]))
