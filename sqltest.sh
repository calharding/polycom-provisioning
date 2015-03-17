#!/bin/bash

DBUSER="corne"
DBPASS="10810cbv"
DBHOST="10.71.0.2"

mysql -N -B -h $DBHOST -u $DBUSER -p${DBPASS} asterisk -e 'select extension,server_ip from phones' | tr "\\t" ","
