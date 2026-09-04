#!/bin/bash

read -p "Enter the number" num 

rem=$((num%2))
if [ $rem == 0 ]
then	
	echo "The number $num is even"
else
	echo "The number $num is odd"
fi




