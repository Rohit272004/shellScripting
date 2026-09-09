#!/bin/bash

path="$1"

if [[ -z "$path" ]]
then 
	echo "Please enter path "
	exit 1 
fi

if [[ ! -d "$path" ]]
then 
	echo "Invalid path"
	exit 1
fi

files=$(find "$path" -type f | wc -l)
directories=$(find "$path" -type d | wc -l)

echo "files : $files"
echo "directories : $directories"

