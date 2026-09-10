#!/bin/bash 

directory="$1"

if [[ -z "$directory" ]]
then 
	echo "Please enter directory"
	exit 1
fi

if [[ ! -d "$directory" ]]
then 
	echo "Please enter valid directory"
	exit 1 
fi

for file in "$directory"/*
do 
	if [[ -f "$file" ]] 
	then 
		echo "$file"
	fi
done

