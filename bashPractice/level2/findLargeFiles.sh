#!/bin/bash

DIRECTORY="$1"
SIZE="$2"

if [ -z "$DIRECTORY" ] || [ -z "$SIZE" ]; then
    echo "Usage: $0 <directory> <size>"
    echo "Example: $0 /home/rohit 100M"
    exit 1
fi

if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi

echo "Files larger than $SIZE:"
echo

find "$DIRECTORY" -type f -size +"$SIZE"