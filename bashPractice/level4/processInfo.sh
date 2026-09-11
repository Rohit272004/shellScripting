#!/bin/bash

if [[ "$#" -ne 1 ]]
then 
	echo "Please enter username as argument"
	exit 1
fi

username="$1"

echo "Process by $username"
echo
ps -u "$username"

