#!/bin/bash

source="$1"
destination="$2"

if [[ -z "$source" ]] || [[ -z "$destination" ]] 
then 
	echo "Please provide source and desitnation path"
	exit 1
fi

if [[ ! -d "$source" ]]
then 
	echo "Error : Source directory  does not exist"
	edit 1
fi

mkdir -p "$destination"
rsync -av  "$source" "$destination"

echo "Backup completed"



