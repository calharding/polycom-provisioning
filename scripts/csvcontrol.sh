#!/bin/bash

ARGS=("$@")

CSVFILE=${ARGS[0]}

while IFS="," read EXT MAC
do
  cp config-template.xml ${MAC}.cfg
done < $CSVFILE
