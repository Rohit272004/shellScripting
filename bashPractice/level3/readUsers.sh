#!/bin/bash 

file="$1"

if [[ -z "$file" ]]
then 
	echo "Please enter file name"
	exit 1
fi 

if [[ ! -f "$file" ]]
then 
	echo "$file does not exist"
	exit 1
fi

while IFS= read -r line
do 
	echo "User : $line"
done < "$file"
