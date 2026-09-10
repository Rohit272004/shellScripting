#!/bin/bash

read -p "Enter the number of even numbers to print " count 

number=2
for(( i = 1 ; i <= $count ; i++ )) 
do
	echo "$number"	
	((number+=2))
done

