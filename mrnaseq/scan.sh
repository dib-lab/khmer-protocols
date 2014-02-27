#!/bin/bash

#set -x

script=${1}.sh
echo ${script}

#clearing out the IFS to make bash not strip out leading whitespace
IFS=''
inshell=FALSE #wrapper
incode=FALSE  #exe code-block flag
looped=FALSE  #switch for end of exe code-block
rm ${script}

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
	if [ "$inshell" = "TRUE" ] && [[ "$line" == "::" ]]
	then
		incode=TRUE
	fi
	if [ "$incode" = "TRUE" ] && ( echo $line | grep '^   ' ) 
	then
		echo $line >> ${script}
		looped=TRUE
	elif [ "$looped" = "TRUE" ] && [ "$line" != "::" ]
	then
		incode=FALSE
		looped=FALSE
	fi
done < $1

#source ${script}
