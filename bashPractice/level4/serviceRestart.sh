#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <service>"
    exit 1
fi

SERVICE="$1"
LOGFILE="service-watchdog.log"

log()
{
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

while true
do
    if systemctl is-active --quiet "$SERVICE"
    then
        log "$SERVICE is running."
	exit 0
    else
        log "WARNING: $SERVICE is not running."
        log "Attempting to restart $SERVICE..."

        if systemctl restart "$SERVICE"
        then
            sleep 2

            if systemctl is-active --quiet "$SERVICE"
            then
                log "$SERVICE restarted successfully."
		exit 0
            else
                log "ERROR: $SERVICE failed to start."
            fi
        else
            log "ERROR: Failed to execute restart."
        fi
    fi

    sleep 5
done
