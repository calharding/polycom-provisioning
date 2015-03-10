#!/bin/bash

#######################################################
# Take 2 commandline arguments: spreadsheet and server IP
# Call various functions:
#
# 1. xlsx.pl converts spreadsheet to CSV. spreadsheet MUST be |EXTENSION|MACADDR|
# 2. csvcontrol.sh creates .cfg file for each MAC address and copies default template to it.
# 3. server-change.sh adds new server IP address to each newly created config.
########################################################

ARGS=("$@")
SPREADSHEET=${ARGS[0]}
SERVER_IP=${ARGS[1]}
CSVFILE="polycom.csv"

./xlsx.pl $SPREADSHEET > $CSVFILE

./csvcontrol.sh $CSVFILE

#./server-change.sh $SERVER_IP
