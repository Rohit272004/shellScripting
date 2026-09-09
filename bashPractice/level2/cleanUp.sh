#!/bin/bash

directory="$1"
days="$2"

if [[ -z "$directory" ]]
then 
    echo "Usage: $0 <directory> <days>"
    echo "Example: $0 /tmp 30"
    exit 1
fi 

if [[ ! -d "$directory" ]]
then 
    echo "Please enter valid Directory"
    exit 1
fi

files=$(find "$directory" -type f -mtime +"$days")

if [[ -z "$files"  ]]
then 
    echo "No files older then $days were found"
    exit 0 
fi 

echo "$files"
echo 

read -p "Do you want to delete these files? [Y/N]" response

if [[ "$response" == "Y" ]] || [[ "$response" == "y" ]]
then 
    for file in $files
    do 
        rm -- "$file"
    done
fi

