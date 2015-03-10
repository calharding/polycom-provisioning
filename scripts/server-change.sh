#!/bin/bash

###########################################################
#
# Change registration server address in all autoprovisioning configs
# to address provided as commandline argument
#
# By changing the CONFIG_LINE variable and removing the check for a valid IP,
# the script becomes extensible and should allow the ability to modify any config option.
#
###########################################################

ARGS=("$@")
CONFIG_LINE="reg.1.server.1.address"


# Check if script argument is a valid IP, otherwise exit immediately.
IP=${ARGS[0]}
OCTET='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'

if [[ $IP =~ ^${OCTET}\.${OCTET}\.${OCTET}\.${OCTET}$ ]]; then
  echo "Valid IP address provided. Continguing with configuration changes..."
else
  echo "Provided IP address invalid. Please run again with a valid IP as argument."
  exit
fi

# If IP address is valid, apply to all configs.
for FILE in $(find . -type f -iname "*.cfg" -print | xargs grep -i "$CONFIG_LINE" | cut -d : -f 1)
  do
    sed -i -e "/${CONFIG_LINE}=/ s/=\".*\"/=\"${IP}\"/" $FILE
    echo "${FILE} has been updated."
done
