#!/bin/bash

showHostname() {
	echo "hostname : $(hostname)"
	echo  
}

showKernel() {
	echo "Kernel : $(uname -r)"
	echo 
}

showUptime() {
	echo "uptime : $(uptime)"
	echo 
}

showMemory() {
	echo "Memory : $(free -h)"
	echo
}

showDisk() {
	echo "Disk : $(df -h)"
	echo
}

echo "System Information"
echo 

showHostname
showKernel
showUptime
showMemory
showDisk


