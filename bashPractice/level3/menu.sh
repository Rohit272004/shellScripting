#!/bin/bash  

switch() {
case "$1" in 
	1) 
		date 
		;;
	2) 
		pwd 
		;;
	3) 
		who 
		;;
	4)
		uptime
		;;
	5) 
		echo  "Exiting..."
		sleep 1s
		exit 0
		;;	
	*)
		echo "Invalid choice"
		;;
esac
}

menu() {
echo "===== Menu ====="
echo
echo "1. Show date"
echo "2. Show current directory"
echo "3. Show logged-in users"
echo "4. Show system uptime"
echo "5. Exit"
echo
read -p "Enter the choice " choice 
}
while true 
do 
	menu
	echo 
	switch "$choice"
	sleep 1s
done
