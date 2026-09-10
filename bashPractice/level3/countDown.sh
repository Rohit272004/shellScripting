#!/bin/bash

read -p "Enter the starting number" number 

while (( number > 0 ))
do 
	echo "$number"
	(( number-- ))
	sleep 1s 
done 
echo "Countdown ends"
