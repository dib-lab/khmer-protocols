#!/bin/bash

#set -x

script=$1.sh

#clearing out the IFS to make bash not strip out leading whitespace
IFS=''
inshell=FALSE

while read line
do
	if [ "$line" = ".. shell:: start" ]
	then
		inshell=TRUE	
	elif [ "$line" = ".. shell:: stop" ]
	then
		inshell=FALSE
	fi
	if [ "$inshell" = "TRUE" ] && ( echo $line | grep '^   ' ) 
	then
		echo $line >> ${script}
	fi
done < $1

#source ${script}
