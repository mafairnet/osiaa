#!/usr/bin/python
from pydub import AudioSegment
from string import Template
import MySQLdb
import warnings
import json
import os
import errno
import shutil
import datetime
import requests
import urllib2
warnings.filterwarnings("ignore")

#CDR_SOURCE DataBase Host
source_db_host = "0.0.0.0"
#CDR_SOURCE Database User
source_db_user = "user"
#CDR_SOURCE Database Password
source_db_password = "pass"
#CDR_SOURCE DataBase Table
source_db_database = "asteriskcdrdb"

#CDR_DESTINATION DataBase Host
destination_db_host = "0.0.0.0"
#CDR_DESTINATION Database User
destination_db_user = "user"
#CDR_DESTINATION Database Password
destination_db_password = "pass"
#CDR_DESTINATION DataBase Table
destination_db_database = "asteriskcdrdb"

export_record_limit = 100
pbx_id = 1

#SQL Query definitions templates
sqlRetrieveLastCDR = 'select * from cdr order by id desc limit 1'
sqlRetrieveCDR = Template('select `calldate`, `clid`, `src`, `dst`, `dcontext`, `channel`, `dstchannel`, `lastapp`, `lastdata`, `duration`, `billsec`, `disposition`, `amaflags`, `accountcode`, `uniqueid`, `userfield`, `did`, `recordingfile`, `cnum`, `cnam`, `outbound_cnum`, `outbound_cnam`, `cdrId` from cdr where cdrId > $id limit $limit')
sqlStoreCDR = Template("INSERT INTO `tcr`.`cdr` (`id`, `pbx`,`calldate`, `clid`, `src`, `dst`, `dcontext`, `channel`, `dstchannel`, `lastapp`, `lastdata`, `duration`, `billsec`, `disposition`, `amaflags`, `accountcode`, `uniqueid`, `userfield`, `did`, `recordingfile`, `cnum`, `cnam`, `outbound_cnum`, `outbound_cnam`) VALUES ('$id', '$pbx','$calldate', '$clid', '$src', '$dst', '$dcontext', '$channel', '$dstchannel', '$lastapp', '$lastdata', '$duration', '$billsec', '$disposition', '$amaflags', '$accountcode', '$uniqueid', '$userfield', '$did', '$recordingfile', '$cnum', '$cnam', '$outbound_cnum', '$outbound_cnam')")

#Retrieve the last cdr
def retrieveLastCDR():
    db = MySQLdb.connect(destination_db_host,destination_db_user,destination_db_password,destination_db_database)
    try:
        cursor = db.cursor()
        print sqlRetrieveLastCDR
        cursor.execute(sqlRetrieveLastCDR)
        row = cursor.fetchone()
    except (MySQLdb.Error, MySQLdb.Warning) as e:
        print(e)
    db.close()
    print(row)
    return row

#Get the next N rows of the cdr after the last registered CDR. N rows number is defined by a limit on the config. 
def retrieveCDR(lastCDR):
    db = MySQLdb.connect(source_db_host,source_db_user,source_db_password,source_db_database)
    try:
        cursor = db.cursor()
        cursor.execute(sqlRetrieveCDR.substitute(id=str(lastCDR),limit=export_record_limit))
        results = cursor.fetchall()
    except (MySQLdb.Error, MySQLdb.Warning) as e:
        print(e)
    db.close()
    return results

#Store the CDR data from the soource table to the destination table
def storeCDR(cdr):
    
    id = cdr[22]
    pbx = pbx_id
    calldate = cdr[0]
    clid = cdr[1]
    src = cdr[2]
    dst = cdr[3]
    dcontext = cdr[4]
    channel = cdr[5]
    dstchannel = cdr[6]
    lastapp = cdr[7]
    lastdata = cdr[8]
    duration = cdr[9]
    billsec = cdr[10]
    disposition = cdr[11]
    amaflags = cdr[12]
    accountcode = cdr[13]
    uniqueid = cdr[14]
    userfield = cdr[15]
    did = cdr[16]
    recordingfile = cdr[17]
    cnum = cdr[18] 
    cnam = cdr[19]
    outbound_cnum = cdr[20]
    outbound_cnam = cdr[21]

    db = MySQLdb.connect(destination_db_host,destination_db_user,destination_db_password,destination_db_database)
    try:
        cursor = db.cursor()
        storeSql = sqlStoreCDR.substitute(id = id, pbx = pbx, calldate = calldate, clid = clid, src = src, dst = dst, dcontext = dcontext, channel = channel, dstchannel = dstchannel, lastapp = lastapp, lastdata = lastdata, duration = duration, billsec = billsec, disposition = disposition, amaflags = amaflags, accountcode = accountcode, uniqueid = uniqueid, userfield = userfield, did = did, recordingfile = recordingfile,cnum = cnum, cnam = cnam, outbound_cnum = outbound_cnum, outbound_cnam = outbound_cnam)
        #print storeSql
        cursor.execute(storeSql)
        print "Insert CDR ID : " + str(id)
        db.commit()
    except (MySQLdb.Error, MySQLdb.Warning) as e:
        db.rollback()
        print(e)
    db.close()

lastStoredCDR = retrieveLastCDR()

if not lastStoredCDR:
    print "Not recording found"
    lastStoredCDRId = 0
else:
    lastStoredCDRId = lastStoredCDR[0]

print lastStoredCDRId

cdrData = retrieveCDR(lastStoredCDRId)

for row in cdrData:
    storeCDR(row)

print str(export_record_limit) + " record exported!"