#!/usr/bin/python
import os
import csv

filename = "fixed_devices.csv"

f = open(filename, 'rt')
try:
    reader = csv.reader(f)
    for row in reader:
        #print row
        fixed_devices = row
finally:
    f.close()

print fixed_devices

cmd = "asterisk -rx 'database show AMPUSER' | /bin/grep device"
cmd_output = os.popen(cmd).read()
#print cmd_output

astdb_data =  cmd_output.split('\n')

for ampuser in astdb_data:
    if "AMPUSER" in ampuser and len(ampuser) > 2:
        ampuser_data = ampuser.split()
        print(ampuser_data)

        if len(ampuser_data) >= 3 and ampuser_data[2] in ampuser_data[0]:
            if any(ampuser_data[2] in s for s in fixed_devices):
                print "Skip"
            else:
                cmd_correct = "asterisk -rx 'database put AMPUSER " + ampuser_data[2] + '/device ""' + "'"
                print "Correcting, running " + cmd_correct
                print os.popen(cmd_correct).read()