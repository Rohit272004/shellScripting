#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <service>"
    exit 1
fi

SERVICE="$1"

if systemctl is-active --quiet "$SERVICE"
then
    echo "$SERVICE: RUNNING"
else
    echo "$SERVICE: NOT RUNNING"
fi


