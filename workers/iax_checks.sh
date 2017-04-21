#!/bin/bash

####### Asterisk Telephony Server
if [ -a /usr/sbin/asterisk ]
then
  #IAXCHANNELS=$(asterisk -rx 'iax2 show channels' | grep active |  cut -d' ' -f1)
  IAXTOTALPEERS=$(asterisk -rx 'iax2 show peers' | grep 'iax2 peers' | cut -d' ' -f1)
  IAXONLINE=$(asterisk -rx 'iax2 show peers' |  grep -o '[0-9]* online' | head -1 | cut -d' ' -f1)
  IAXOFFLINE=$(asterisk -rx 'iax2 show peers' | grep -o '[0-9]* offline' | head -1 | cut -d' ' -f1)

  echo "Total IAX2 Peers:$IAXTOTALPEERS"
  echo "IAX2 Peers Online:$IAXONLINE"
  echo "IAX2 Peers Offline: $IAXOFFLINE"

  if [ $IAXOFFLINE != 0  ];
  then
	IAXOFFLINE=$(service asterisk reload)
	echo "Trying to reconnect IAX2 peers by SERVCE ASTERISK RELOAD"
  else
        echo "All IAX2 Peers Online"
  fi

fi
