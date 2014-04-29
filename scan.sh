#!/bin/bash

# Originally authored by Leigh Sheneman for the khmer-protocols
# project.  Transferred w/o change to literate-resting project by
# C. Titus Brown and updated thereafter as in the git log
# (see: github.com/ged-lab/literate-resting)

#set -x

script=${1}.sh
echo ${script}

#clearing out the IFS to make bash not strip out leading whitespace
IFS=''
inshell=FALSE #wrapper
incode=FALSE  #exe code-block flag
looped=FALSE  #switch for end of exe code-block
rm -f ${script}

#clearing out the IFS to make bash not strip out leading whitespace
IFS=''
inshell=FALSE

while read line
do
	if [ "$line" = ".. shell start" ]
	then
		inshell=TRUE	
	elif [ "$line" = ".. shell stop" ]
	then

		inshell=FALSE
	fi
	if [ "$inshell" = "TRUE" ] && [[ "$line" == "::" ]]
	then
		incode=TRUE
	elif [ "$inshell" = "TRUE" ] && [[ "$line" == ".. ::" ]]
	then
		incode=TRUE
	fi

	if [ "$incode" = "TRUE" ] && ( echo $line | grep '^   ' > /dev/null ) 
	then
		echo $line | cut -c4- >> ${script}
		looped=TRUE
	elif [ "$looped" = "TRUE" ] && [ "$line" != "::" ]
	then
		incode=FALSE
		looped=FALSE
	fi
done < $1

#source ${script}
