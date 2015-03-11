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

# First commandline argument. The name of the spreadsheet with the extensions and macs.
SPREADSHEET=${ARGS[0]}

# Second commandline argument. The IP address of the server to use.
SERVER_IP=${ARGS[1]}

# The filename you want to use for the CSV to be generated from spreadsheet.
CSVFILE="polycom.csv"

# The path to the template that all configs will be based on.
CONFIGTEMPLATE="config-template.xml"

# The line in the newly generated config to use for the server IP address.
CONFIG_SERVER_LINE="reg.1.server.1.address"

# TFTP directory
TFTP_DIR="/tftpboot/"

# Run the perl script to generate a CSV from xlsx file
./xlsx.pl $SPREADSHEET > $CSVFILE



#./csvcontrol.sh $CSVFILE

while IFS="," read EXT MAC
do
  cp -f ${TFTP_DIR}/${CONFIGTEMPLATE} ${TFTP_DIR}/${MAC}-basic.cfg
  sed -i "s/1113/${EXT}/g" ${TFTP_DIR}/${MAC}-basic.cfg
done < $CSVFILE

#./server-change.sh $SERVER_IP

###########################################################
# Change registration server address in all autoprovisioning configs
# to address provided as commandline argument
#
# By changing the CONFIG_SERVER_LINE variable and removing the check for a valid IP,
# the script becomes extensible and should allow the ability to modify any config option.
#
############################################################


# Check if script argument is a valid IP, otherwise exit immediately.
OCTET='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'

if [[ $SERVER_IP =~ ^${OCTET}\.${OCTET}\.${OCTET}\.${OCTET}$ ]]; then
  echo "Valid IP address provided. Continguing with configuration changes..."
else
  echo "Provided IP address invalid. Please run again with a valid IP as argument."
  exit
fi

# If IP address is valid, apply to all configs.
for FILE in $(find ${TFTP_DIR} -type f -iname "*-basic.cfg" -print | xargs grep -i "$CONFIG_SERVER_LINE" | cut -d : -f 1)
  do
    sed -i -e "/${CONFIG_SERVER_LINE}=/ s/=\".*\"/=\"${SERVER_IP}\"/" $FILE
    echo "${FILE} has been updated."
done
