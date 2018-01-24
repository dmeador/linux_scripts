#!/bin/bash

while getopts ":b" opt; do
	case ${opt} in
	b ) # process option b -- bare listing
		BARE_LISTING=true
		;;
	esac
	shift $((OPTIND -1))
done

for file in $*; do
	ENC=`file --mime-encoding ${file} | cut -f 2 -d':' | sed -e 's/^[[:space:]]*//'`	
	if [ "$ENC" == "us-ascii" ] || [ "$ENC" == "utf-8" ]; then
		sed -i 's/\r//' "${file}";
	fi
done
