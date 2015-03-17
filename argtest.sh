#!/bin/bash

ARGS=("$@")

FIRSTARG=${ARGS[0]}

SECARG=${ARGS[1]}

#if (( $# != 2 ))
#then
#  echo "Usage: ..."
#  exit 1
#fi


if [ -z $SECARG ]
then
  echo "\$SECARG not set"
  exit 1
else
  echo "\$SECARG variable set to $SECARG"
fi
