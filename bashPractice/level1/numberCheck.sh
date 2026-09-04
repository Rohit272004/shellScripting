#!/bin/bash

read -p "Enter the number" num

if [[ $num -gt 0 ]]
then 
	echo "The number is positive"
#spacing matters alot in conditions 
elif [[ $num -eq  0 ]]
then 
	echo "The number is zero"
else 
	echo "The number is negative"
fi

