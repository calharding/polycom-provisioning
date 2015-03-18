#!/bin/bash

DBUSER="corne"
DBPASS="10810cbv"
DBHOST="10.71.0.2"

mysql -N -B -h $DBHOST -u $DBUSER -p${DBPASS} asterisk -e 'select extension,server_ip from phones' | tr "\\t" "," > sql.tmp


declare -A SERVER
while IFS=, read -r -a array
do 
    ((${#array[@]} >= 2)) || continue
    SERVER["${array[@]:0:1}"]="${array[@]:1}"
done < sql.tmp

for key in "${!SERVER[@]}"
do
    echo "${key} ---> ${SERVER[${key}]}"
done

echo "Extension 1086 goes to server ${SERVER[1086]}"
echo "extension 1017 goes to server ${SERVER[1017]}"
