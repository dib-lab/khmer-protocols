#!/bin/bash

#set -x

script=$1.sh
<<<<<<< HEAD
echo > ${script}

#clearing out the IFS to make bash not strip out leading whitespace
IFS=''
inshell=FALSE #wrapper
incode=FALSE  #exe code-block flag
looped=FALSE  #switch for end of exe code-block
=======
rm = $1.sh

#clearing out the IFS to make bash not strip out leading whitespace
IFS=''
inshell=FALSE
>>>>>>> 3dddaf7e3269d2a9bc9ae704621192f0e6d5b993

while read line
do
	if [ "$line" = ".. shell:: start" ]
	then
<<<<<<< HEAD
		
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
=======
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
>>>>>>> 3dddaf7e3269d2a9bc9ae704621192f0e6d5b993
