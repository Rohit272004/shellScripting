#!/bin/bash

logFile="serverCheck.log"

log() {
	if [[ ! -f "$logFile" ]] 
	then 
		touch serverCheck.log
	fi

	echo "$(date) -$1" | tee -a "$logFile"
}

hostName=$(hostname)
log "hostname : $hostName"

log "uptime : $(uptime)"


disk=$(df / -h | awk 'NR==1 {next} {gsub("%","",$5) ; print $5}')
#checkd disk usage
if [[ $((disk > 20)) ]]
then 
	log "Warning : Disk Usage is ${disk}%"
else 
	log "Disk : OK - ${disk}%"
fi

#Check memory usage
memory=$(free | awk '/Mem:/ {printf "%.0f\n", ($3/$2)*100}')

if [[ "$memory" -ge 80 ]] 
then 
	log "Warning : Memory Usage ${memory}%"
else 
	log "Memory : Ok ${memory}%"
fi

#check /var/log/

if [[ -d "/var/log" ]]
then 
	log "/var/log : exsist"
else 
	log "/var/log : Does not exists"
fi



