#!/bin/bash

#######################################################
# Take 2 commandline arguments: spreadsheet and server IP
#
# Set registration server in configs to server IP. If no
# server IP provided, look up extensions and their
# associated server addresses in (SQL) database.
########################################################

#############################
# Begin variable declarations
#############################

# commandline arguments
ARGS=("$@")

# First commandline argument. The name of the spreadsheet with the extensions and macs.
SPREADSHEET=${ARGS[0]}

# Second commandline argument. The IP address of the server to use.
SERVER_IP=${ARGS[1]}

# Default server address when nothing specified and no DB server info can be found.
DEF_SERVER="192.168.192.168"

# The filename you want to use for the CSV to be generated from spreadsheet.
CSVFILE="polycom.csv"

# The path to the template that all configs will be based on.
CONFIGTEMPLATE="config-template.xml"

# The line in the newly generated config to use for the server IP address.
# reg.1.server.1.address may not be correct and is just temporary
CONFIG_SERVER_LINE="voIpProt.server.1.address"

# TFTP directory
TFTP_DIR="/tftpboot/"

#Database variables
DBUSER="corne"
DBPASS="10810cbv"
DBHOST="10.71.0.2"
DBTMPFILE="sql.tmp"

###########################
# End variable declarations
###########################

# If the SERVER_IP variable is not set, default to 0.0.0.0 (DB lookup values)
if [ -z $SERVER_IP ]; then
  SERVER_IP="0.0.0.0"
fi


# Run the perl script to generate a CSV from xlsx file
./xlsx.pl $SPREADSHEET > $CSVFILE


# DB CODE
# Creates an associative array with extension as key and server (pulled from DB) as value.
mysql -N -B -h $DBHOST -u $DBUSER -p${DBPASS} asterisk -e 'select extension,server_ip from phones' | tr "\\t" "," > $DBTMPFILE
# Declare and populate associative array. KEY=extension, VALUE=server
declare -A SERVER
while IFS=, read -r -a array
do
    ((${#array[@]} >= 2)) || continue
    SERVER["${array[@]:0:1}"]="${array[@]:1}"
done < $DBTMPFILE


# Read CSV. For each MAC address, make a config file and set correct extensions within that file.
# And in each file, enter the correct server line according to DB array
while IFS="," read EXT MAC
do
  cp -f ${TFTP_DIR}/${CONFIGTEMPLATE} ${TFTP_DIR}/${MAC,,}-basic.cfg
  # If extension in CSV/spreadsheet does not have associated DB server, set server value to default
  if [ -z ${SERVER[${EXT}]} ]; then
    SERVER[${EXT}]="${DEF_SERVER}"
  fi
  # Do replacements
  sed -i "s/1113/${EXT}/g" ${TFTP_DIR}/${MAC,,}-basic.cfg
  sed -i -e "/${CONFIG_SERVER_LINE}=/ s/=\".*\"/=\"${SERVER[${EXT}]}\"/g" ${TFTP_DIR}/${MAC,,}-basic.cfg
done < $CSVFILE


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
if [ "$SERVER_IP" != "0.0.0.0" ]; then
  for FILE in $(find ${TFTP_DIR} -type f -iname "*basic.cfg" -print | xargs grep -i "$CONFIG_SERVER_LINE" | cut -d : -f 1)
    do
      sed -i -e "/${CONFIG_SERVER_LINE}=/ s/=\".*\"/=\"${SERVER_IP}\"/g" $FILE
#      echo "${FILE} has been updated."
  done
fi


# Cleanup
rm -f $DBTMPFILE
rm -f $CSVFILE
