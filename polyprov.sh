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
# reg.1.server.1.address may not be correct and is just temporary
CONFIG_SERVER_LINE="reg.1.server.1.address"

# TFTP directory
TFTP_DIR="/tftpboot/"

#Database variables
DBUSER="corne"
DBPASS="10810cbv"
DBHOST="10.71.0.2"
DBTMPFILE="sql.tmp"


# Run the perl script to generate a CSV from xlsx file
./xlsx.pl $SPREADSHEET > $CSVFILE


# DB CODE
# Creates an associative array with extension as key and server (pulled from DB) as value.
mysql -N -B -h $DBHOST -u $DBUSER -p${DBPASS} asterisk -e 'select extension,server_ip from phones' | tr "\\t" "," > $DBTMPFILE

declare -A SERVER
while IFS=, read -r -a array
do
    ((${#array[@]} >= 2)) || continue
    SERVER["${array[@]:0:1}"]="${array[@]:1}"
done < $DBTMPFILE


#./csvcontrol.sh $CSVFILE

# Read CSV. For each MAC address, make a config file and set correct extensions within that file.
# And in each file, enter the correct server line according to DB array
while IFS="," read EXT MAC
do
  cp -f ${TFTP_DIR}/${CONFIGTEMPLATE} ${TFTP_DIR}/${MAC}-basic.cfg
  sed -i "s/1113/${EXT}/g" ${TFTP_DIR}/${MAC}-basic.cfg
  sed -i -e "/${CONFIG_SERVER_LINE}=/ s/=\".*\"/=\"${SERVER[${EXT}]}\"/g" ${TFTP_DIR}/${MAC}-basic.cfg
#  echo ${SERVER[${EXT}]}
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
#OCTET='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
#
#if [[ $SERVER_IP =~ ^${OCTET}\.${OCTET}\.${OCTET}\.${OCTET}$ ]]; then
#  echo "Valid IP address provided. Continguing with configuration changes..."
#else
#  echo "Provided IP address invalid. Please run again with a valid IP as argument."
#  exit
#fi

# If the server IP passed as a commandline argument DOES NOT equal 0.0.0.0, then
# overwrite the values pulled from the DB and set that globally as the server address.
#if [ $SERVER_IP does not equal 0.0.0.0 ] #pseudocode for now. please fix.
#  for FILE in $(find ${TFTP_DIR} -type f -iname "*basic.cfg" -print | xargs grep -i "$CONFIG_SERVER_LINE" | cut -d : -f 1)
#    do
#      sed -i -e "/${CONFIG_SERVER_LINE}=/ s/=\".*\"/=\"${SERVER_IP}\"/g" $FILE
#      echo "${FILE} has been updated."
#  done
#fi


# Cleanup
rm -f $DBTMPFILE
rm -f $CSVFILE


# TODO
# create ${MAC}-basic.cfg as both upper and lowercase
# 
# If extension exists in the spreadsheet but NOT the DB, set server address as the current genesys address.
