#!/usr/bin/python
import os
import csv

filename = "registered_devices.csv"

f = open(filename, 'rt')
try:
    reader = csv.reader(f)
    for row in reader:
        #print row
        fixed_devices = row
finally:
    f.close()

print fixed_devices

cmd = "asterisk -rx 'database show DEVICE'"
cmd_output = os.popen(cmd).read()
#print cmd_output

astdb_data =  cmd_output.split('\n')

for device in astdb_data:
    if "DEVICE" in device and len(device) > 2:
        device_data = device.split()
        print(device_data)

        if len(device_data) >= 3:
            device_reg = device_data[0].split('/')
            device_id = device_reg[2]
            print device_id
            if any(device_id in s for s in fixed_devices):
                print "Skip"
            else:
                #print "=============================================CHK!"
                cmd_correct = "asterisk -rx 'database del DEVICE " + device_reg[2] + '/' + device_reg[3] + "'"
                print "Correcting, running " + cmd_correct
                print os.popen(cmd_correct).read()