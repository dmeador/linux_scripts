#!/bin/bash

BARE_LISTING=
while getopts ":b" opt; do
	case ${opt} in
	b ) # process option b -- bare listing
		BARE_LISTING=true
		;;
	esac
	shift $((OPTIND -1))
done

for file in $*; do

	ANY_R_FOUND=`awk '/\r/ { print $0 }' ${file} | wc -l`
	if [ $ANY_R_FOUND -gt 0 ]; then
		if [ $BARE_LISTING ]; then
			echo "${file}" ;
		else	
			echo "${file} : [${ANY_R_FOUND} / `cat ${file} | wc -l`]" ;
		fi
	fi
done
