#!/bin/bash

declare -A array

array[myname]="Cal"
array[mysurname]="Harding"
array[dob]="1983-09-26"

echo "My name is ${array[myname]} and my surname is ${array[mysurname]}. I was born on ${array[dob]}. Have a nice day."

