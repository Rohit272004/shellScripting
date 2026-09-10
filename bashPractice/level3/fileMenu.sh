#!/bin/bash

read -p "Enter the file name " file

echo
echo "1. Check existence"
echo "2. Show contents"
echo "3. Count lines"
echo "4. Show size"
echo "5. Exit"
echo

read -p "Enter choice " choice

case "$choice" in 
	1) 
		if [[ -f "$file" ]] 
		then 
			echo "File exists"
		else 
			echo "File does not exists"
		fi
		;;
	2)
		if [ -f "$file" ]; then
	           	 cat "$file"
       		else
           		 echo "File does not exist."
        	fi
       		;;
	3)
                if [ -f "$file" ]; then
           	 	cat "$file" | wc -l
        	else
            		echo "File does not exist."
        	fi
        	;;
	4)
		if [ -f "$file" ]; then
           	 	du -h "$file"
        	else
            		echo "File does not exist."
        	fi
        	;;
	5) 
		echo "Exiting"
		exit 0 
		;;
	*) 
		echo "Invalid choice"
		;;
esac


