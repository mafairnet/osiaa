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

cmd = "asterisk -rx 'database show DEVICE' | grep /default_user"
cmd_output = os.popen(cmd).read()
#print cmd_output

astdb_data =  cmd_output.split('\n')

for device in astdb_data:
    if "DEVICE" in device and len(device) > 2:
        device_data = device.split()
        print(device_data)

        if len(device_data) >= 3 and device_data[2] in device_data[0]:
            if any(device_data[2] in s for s in fixed_devices):
                print "Skip"
            else:
                if "/default_user" in device_data[0]:
                    cmd_correct = "asterisk -rx 'database put DEVICE " + device_data[2] + '/default_user none' + "'"
                elif "/user" in device_data[0]:
                    cmd_correct = "asterisk -rx 'database put DEVICE " + device_data[2] + '/user none' + "'"
                print "Correcting, running " + cmd_correct
                print os.popen(cmd_correct).read()