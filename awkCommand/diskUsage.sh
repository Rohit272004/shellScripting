#!/bin/bash

df -h | awk 'NR == 1 {next} {
	usage = $5
	gsub("%","",usage )

	if(usage > 80){
		print "Warning" ,$1 ,"is" , usage "% full"
	}
	else {
		print $1 , "is not using too much space"
	}
}
	'

