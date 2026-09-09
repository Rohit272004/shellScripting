#!/bin/bash

DIRECTORY="$1"
DAYS="$2"

if [ -z "$DIRECTORY" ] || [ -z "$DAYS" ]; then
    echo "Usage: $0 <directory> <days>"
    echo "Example: $0 /var/log 30"
    exit 1
fi

if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory does not exist."
    exit 1
fi

echo "Files older than $DAYS days:"
echo

find "$DIRECTORY" -type f -mtime +"$DAYS" -print